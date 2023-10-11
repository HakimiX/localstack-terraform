# LocalStack Terraform 

Sample terraform project to deploy AWS resources to localstack. 

## Prerequisites

* [Docker](https://docs.docker.com/install/)
* [Terraform](https://www.terraform.io/downloads.html)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* [LocalStack](https://docs.localstack.cloud/getting-started/installation/)

## Setup

The docker-compose file will start LocalStack and a Postgres database.

1. Start localstack

    ```bash
    TMPDIR=/private$TMPDIR docker-compose up
    ```


## AWS CLI with LocalStack

SQS commands: 
```bash
# list queues 
aws --endpoint-url=http://localhost:4566 sqs list-queues

# send message to queue
aws --endpoint-url=http://localhost:4566 sqs send-message --queue-url <queue-url>  --message-body "Hello World"

# purge queue 
aws --endpoint-url=http://localhost:4566 sqs purge-queue --queue-url <queue-url>
```