import boto3
import json

def lambda_handler(event, context):
    print("Received event:", json.dumps(event, indent=4))

    return {
        'statusCode': 200,
        'body': 'success'
    }