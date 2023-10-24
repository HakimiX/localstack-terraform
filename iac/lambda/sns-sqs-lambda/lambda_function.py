import boto3
import json

def lambda_handler(event, context):

    # Log the incoming event
    print("Received event:", json.dumps(event, indent=4))

    return {
        'statusCode': 200,
        'body': 'success'
    }

    
def comment():
    sqs = boto3.client('sqs')
    queue_url = 'http://localhost:4566/000000000000/sample-queue'  # You need to provide the actual URL here

    # Read messages from the SQS queue
    response = sqs.receive_message(
        QueueUrl=queue_url,
        MaxNumberOfMessages=10
    )

    messages = response.get('Messages', [])

    for message in messages:
        print("Received message:", message['Body'])

        # Delete the message from the queue
        sqs.delete_message(
            QueueUrl=queue_url,
            ReceiptHandle=message['ReceiptHandle']
        )

    return {
        'statusCode': 200,
        'body': json.dumps('Messages processed!')
    }

    # Assuming the SNS message is the SQS message we want
    #for record in event['Records']:
    #    message_body = json.loads(record['Sns']['Message'])
    #    sqs.send_message(QueueUrl=queue_url, MessageBody=message_body)

    #return {
    #    'statusCode': 200,
    #    'body': json.dumps('Message sent to SQS!')
    #}