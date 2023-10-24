# LocalStack Terraform 

Sample terraform project to deploy AWS resources to localstack. 

- [LocalStack Terraform](#localstack-terraform)
  - [Prerequisites](#prerequisites)
  - [Setup](#setup)
      - [Stopping the containers](#stopping-the-containers)
  - [AWS CLI with LocalStack](#aws-cli-with-localstack)
    - [See lambda logs](#see-lambda-logs)
  - [Troubleshoot](#troubleshoot)
      - [InvalidClientTokenId](#invalidclienttokenid)
      - [(ResourceNotFoundException) when calling the GetLogEvents operation](#resourcenotfoundexception-when-calling-the-getlogevents-operation)
    - [Sources](#sources)


## Prerequisites

* [Docker](https://docs.docker.com/install/)
* [Terraform](https://www.terraform.io/downloads.html)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)
* [LocalStack](https://docs.localstack.cloud/getting-started/installation/)

## Setup

The docker-compose file will start LocalStack and a Postgres database.

1. Run `docker-compose up` to start LocalStack and Postgres

```bash
docker compose -f docker-compose.localstack.yml up
```

![](resources/images/localstack-containers.png)

2. Run `terraform init` to initialize the terraform project

```bash
cd iac
terraform init
```
3. Run `terraform plan` to see the resources that will be created

```bash
terraform plan
```
4. Run `terraform apply` to create the resources

```bash
terraform apply
```

![](resources/images/terraform-apply.png)

#### Stopping the containers

:warning: LocalStack resources will be destroyed. 
```bash
docker compose -f docker-compose.localstack.yml down
```

## AWS CLI with LocalStack
Use the AWS CLI to interact with the resources created in LocalStack.

**SQS**
```shell
# list-queues
aws --endpoint-url=http://localhost:4566 sqs list-queues

# Send SQS messages
aws --endpoint-url=http://localhost:4566 sqs send-message --queue-url http://localhost:4566/000000000000/my-simple-queue --message-body "Hello World"

# Purge SQS queue
aws --endpoint-url=http://localhost:4566 sqs purge-queue --queue-url http://localhost:4566/000000000000/my-simple-queue
```

**topics**
```shell
# list-topics
aws --endpoint-url=http://localhost:4566 sns list-topics

# publish message
aws --endpoint-url=http://localhost:4566 sns publish --topic-arn YOUR_SNS_TOPIC_ARN --message "Your message content here"
```

**lambda**
```shell
# list-functions
aws --endpoint-url=http://localhost:4566 lambda list-functions
```

### See lambda logs 
In LocalStack, when a Lambda function is executed, the logs are printed directly to the console or terminal where LocalStack is running. 

1. You need to create a log group first by invoking the function:
```shell
# Invoke function
aws --endpoint-url=http://localhost:4566 lambda invoke --function-name <function-name> output.txt
```
2. Get logstream name 
```shell
aws --endpoint-url=http://localhost:4566 logs describe-log-streams --log-group-name /aws/lambda/<lamda-name>

# returns logstream name
{
  "logStreams": [
    {
      "logStreamName": "2023/10/24/[$LATEST]f70bcaaf487f9437979a940aeadae856",
    }
}
```
3. Get logs
```shell
aws --endpoint-url=http://localhost:4566 logs get-log-events --log-group-name /aws/lambda/<lambda-name> --log-stream-name '2023/10/24/[$LATEST]f70bcaaf487f9437979a940aeadae856'

# returns logs 
{
  "events": [
    {
        "timestamp": 1698142320794,
        "message": "START RequestId: 95792e66-c37a-469f-bc9c-fc6e72b427be Version: $LATEST",
        "ingestionTime": 1698142320830
    },
    {
        "timestamp": 1698142320800,
        "message": "[ERROR] Runtime.ImportModuleError: ....",
        "ingestionTime": 1698142320830
    },
}
```
> You must use single quotes when specifying `--log-stream-name`, i.e. `'2023/10/24/[$LATEST]f70bcaaf487f9437979a940aeadae856'`

## Troubleshoot

#### InvalidClientTokenId
```shell
Error: reading SQS Queue (http://localhost:4566/000000000000/sample-queue): InvalidClientTokenId: The security token included  in the request is invalid.
  status code: 403, request id: a60820d0-edb9-5681-8b43-7d61785b1da1
  with aws_sqs_queue.sample_queue,
  on main.tf line 26, in resource "aws_sqs_queue" "sample_queue":
  26: resource "aws_sqs_queue" "sample_queue" {
```
Solution: 
```shell
# The error is caused by the AWS CLI not being able to authenticate with LocalStack.
# You need to define the endpoint in the aws provider 

provider "aws" {
  endpoints {
    sqs = "http://localhost:4566"
    # the rest of the resource endpoints (lambda, sns, etc)
  }
}
```

#### (ResourceNotFoundException) when calling the GetLogEvents operation
```shell
An error occurred (ResourceNotFoundException) when calling the GetLogEvents operation: The specified log group does not exist
```
Solution: 
1. Ensure the Log Group Exists: <br>
Before trying to fetch logs from a specific stream, make sure the log group exists. You can list all available log groups in LocalStack:
```shell
aws --endpoint-url=http://localhost:4566 logs describe-log-groups
```
If `/aws/lambda/example_lambda` is not listed, then you'll need to create it first.
2. Create the Log Group (if it doesn't exist):
```shell
aws --endpoint-url=http://localhost:4566 logs create-log-group --log-group-name /aws/lambda/example_lambda
```
3. Ensure the Log Stream Exists:<br>
After confirming or creating the log group, check if the log stream you're trying to fetch logs from exists:
```shell
aws --endpoint-url=http://localhost:4566 logs describe-log-streams --log-group-name /aws/lambda/example_lambda
```
This will list all log streams within the specified log group. Ensure your log stream `2023/10/24/[$LATEST]f70bcaaf487f9437979a940aeadae856`` is listed.

### Sources

* [aws-localstack-examples](https://gist.github.com/sats17/493d05d8d4dfd16b7dad399163075156)