# 1. Start the Docker containers using docker-compose up -d (the -d flag starts the containers in detached mode).
# 2. Check whether the SQS queue exists by running aws --endpoint-url=http://localhost:4566 sqs list-queues.
# 3. Run terraform apply if the SQS queue exists.

.PHONY: clear-tfstate

# Start the Docker containers
clear-tfstate:
	@echo "Clearing terraform state..."
	cd iac && rm terraform.tfstate && rm terraform.tfstate.backup && rm .terraform.lock.hcl
	@echo "Done!"

