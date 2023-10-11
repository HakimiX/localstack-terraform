# 1. Start the Docker containers using docker-compose up -d (the -d flag starts the containers in detached mode).
# 2. Check whether the SQS queue exists by running aws --endpoint-url=http://localhost:4566 sqs list-queues.
# 3. Run terraform apply if the SQS queue exists.

.PHONY: start stop terraform-conditional-apply

start: docker-up terraform-conditional-apply

# Start the Docker containers
docker-up:
	@echo "Starting Docker containers..."
	docker-compose -f docker-compose.localstack.yml up -d
	@echo "Docker containers are up."

# Conditionally apply Terraform code based on SQS queue existence
terraform-conditional-apply:
	@echo "Checking for SQS queue..."
	@if aws --endpoint-url=http://localhost:4566 sqs list-queues 2>/dev/null | grep "http://localhost:4566/000000000000/my-simple-queue" > /dev/null; then \
		echo "SQS queue exists. Skipping Terraform apply."; \
	else \
		echo "SQS queue does not exist. Applying Terraform code."; \
		if [ -f "iac/terraform.tfstate" ]; then \
			rm iac/terraform.tfstate; \
			echo "Removed existing terraform.tfstate file."; \
		fi; \
		cd iac && terraform init; \
		cd iac && terraform apply -auto-approve; \
		echo "Terraform code applied successfully."; \
	fi

# Stop the Docker containers
stop:
	@echo "Stopping Docker containers..."
	docker-compose -f docker-compose.localstack.yml stop
	@echo "Docker containers are stopped."
