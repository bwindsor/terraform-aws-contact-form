import base64
import boto3
from boto3.dynamodb.conditions import Attr
from typing import Optional
import json
import os
import uuid
from urllib.parse import parse_qs

DATABASE_TABLE_NAME = os.environ['DATABASE_TABLE_NAME']
IS_MESSAGE_REQUIRED = bool(int(os.environ['IS_MESSAGE_REQUIRED']))
ACCESS_CONTROL_ALLOWED_ORIGINS = [s.strip() for s in os.environ['ACCESS_CONTROL_ALLOWED_ORIGINS'].split(',')]
ENABLE_EMAIL_FORWARD = bool(int(os.environ['ENABLE_EMAIL_FORWARD']))
if ENABLE_EMAIL_FORWARD:
    FROM_EMAIL_ADDRESS = os.environ['FROM_EMAIL_ADDRESS']
    TARGET_EMAIL_ADDRESSES = [s.strip() for s in os.environ['TARGET_EMAIL_ADDRESSES'].split(',')]

ses_client = boto3.client('ses')

dynamodb_resource = boto3.resource('dynamodb')
dynamodb_table = dynamodb_resource.Table(DATABASE_TABLE_NAME)


def handler(event, context):
    body = event['body']
    if event['isBase64Encoded'] is True:
        body = base64.b64decode(body).decode('utf8')

    form_data = {k: v[-1] for k, v in parse_qs(body).items()}
    if not validate_contact_form(form_data):
        return make_error_response(400, "Invalid form data", event)

    try:
        save_contact_form_to_database(form_data)
        if ENABLE_EMAIL_FORWARD:
            forward_contact_form_to_email(form_data)
    except Exception as e:
        print(str(e))
        return make_error_response(400, "An unexpected error occurred", event)

    return make_response(201, "", event, content_type="text/plain")


def validate_contact_form(form_data: dict) -> bool:
    valid = True
    if 'name' not in form_data:
        valid = False
    if 'email' not in form_data:
        valid = False
    if IS_MESSAGE_REQUIRED and 'message' not in form_data:
        valid = False

    if not valid:
        print(f"Invalid form data: {form_data}")
    return valid


def save_contact_form_to_database(form_data: dict):
    name = form_data['name']
    email = form_data['email']
    message = form_data.get('message')

    submission_id = uuid.uuid4().hex

    item = dict(
        email=email,
        submission_id=submission_id,
        name=name,
    )
    if IS_MESSAGE_REQUIRED:
        item.update(message=message)

    dynamodb_table.put_item(
        Item=item,
        # Check we don't end up with a duplicate submission ID, shouldn't even happen though
        ConditionExpression=Attr("email").not_exists()
    )


def forward_contact_form_to_email(form_data: dict):
    name = form_data['name']
    email = form_data['email']
    message = form_data['message']

    print(f"Attempting to send email message")
    ses_client.send_email(
        Source=f"Contact form - {name} <{FROM_EMAIL_ADDRESS}>",
        Destination={
            "ToAddresses": TARGET_EMAIL_ADDRESSES
        },
        Message={
            "Subject": {
                "Data": f"Contact form from {name}"
            },
            "Body": {
                "Text": {
                    "Data": message
                }
            }
        },
        ReplyToAddresses=[
            f"{name} <{email}>"
        ]
    )


def make_error_response(status_code: int, error_message: str, source_event: dict):
    return make_response(status_code, json.dumps({"message": error_message}), source_event)


def make_response(status_code: int, body: str, source_event: dict, *,
                  content_type: Optional[str] = "application/json", extra_headers: dict = None,
                  is_base64_encoded: bool = False):
    """
    Makes a lambda response object
    :param status_code: status code to respond with
    :param body: response body
    :param source_event: source lambda event, from with origin header can be extracted for CORS response
    :param content_type: content type for the response
    :param extra_headers: additional headers to include in the response
    :param is_base64_encoded: whether response body is base 64 encoded
    :return: object - lambda response
    """
    response = {
        "statusCode": status_code,
        "headers": {
            **({"Content-Type": content_type} if content_type is not None else {}),
            **(extra_headers if extra_headers is not None else {})
        },
        "body": body,
        "isBase64Encoded": is_base64_encoded
    }
    headers = source_event.get("headers")
    if headers is not None:
        origin = headers.get("origin")
        if origin is None:
            origin = headers.get("Origin")
        if origin is not None:
            if origin in ACCESS_CONTROL_ALLOWED_ORIGINS:
                response["headers"]["Access-Control-Allow-Origin"] = origin
    return response
