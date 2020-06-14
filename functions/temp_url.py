import json
import logging
import boto3
import os
import uuid

s3 = boto3.resource('s3')

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    logger.info("Event received.")
    logger.info("Received event: " + json.dumps(event))
    filename = str(uuid.uuid4()) + '.jpg'
    return {"statusCode": 200, "body": json.dumps(_get_post_form(filename))}

def _get_post_form(filename):
    # Generate random filename
    bucket_name = os.environ['IMAGE_REKOGNITION_UPLOAD_BUCKET_NAME']
    expiration = os.environ['IMAGE_REKOGNITION_UPLOAD_EXPIRATION']
    # Generate a presigned URL for the S3 object
    s3_client = boto3.client('s3')
    response = s3_client.generate_presigned_post(Bucket=bucket_name,Key=filename)

    # The response contains the presigned URL
    logger.info('URL generated: ' + str(response))
    form_fields = {'url': "https://{bucket_name}.s3.amazonaws.com/".format(bucket_name=bucket_name)}
    for key, value in response['fields'].items():
        form_fields.update({key:value})
    return form_fields