SSM_TAG = ssm-ec2
SSM_INSTANCE := $(shell aws ec2 describe-instances --filter "Name=tag:Name,Values=$(SSM_TAG)" --query "Reservations[].Instances[?State.Name == 'running'].InstanceId[]" --output text)
#Terraform directory
TF_DIR = terraform/environments/base-example
#Terraform binary alias
TF = terraform
BE_DIR = backend
PACKAGED_TEMPLATE = packaged.yaml
S3_BUCKET = dev-base-backend-build
STACK_NAME = dev-shift
TEMPLATE = template.yml
PORT = 9000

####################
#Backend commands
be-build:
	@cd $(BE_DIR) && $(MAKE) build

.PHONY: up-be
up-be: be-build
	@docker-compose up

####################

####################
#Terraform commands
.PHONY: tf-init
tf-init:
	@cd $(TF_DIR) && $(TF) init

.PHONY: tf-plan
tf-plan: tf-init
	@cd $(TF_DIR) && $(TF) plan

.PHONY: tf-apply
tf-apply: be-build tf-plan
	@cd $(TF_DIR) && $(TF) apply

.PHONY: tf-destroy
tf-destroy: tf-plan
	@cd $(TF_DIR) && $(TF) destroy
####################

####################
#SSM command
.PHONY: ssm-instance
ssm-instance:
	@echo Connecting to SSM INSTANCE
	@aws ssm start-session --target $(SSM_INSTANCE)

####################
