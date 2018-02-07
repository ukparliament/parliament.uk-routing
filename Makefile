.PHONY: build run dev test push scan-image rmi deploy-ecs airbrake

##
# Makefile used to build, test and (locally) run the parliament.uk-prototype project.
##

##
# ENVRONMENT VARIABLES
#   We use a number of environment  variables to customer the Docker image createad at build time. These are set and
#   detailed below.
##

# App name used to created our Docker image. This name is important in the context of the AWS docker repository.
APP_NAME = parliamentukrouting

# AWS account ID used to create our Docker image. This value is important in the context of the AWS docker repository.
# When executed in GoCD, AWS_ACCOUNT_ID may be set by an environment variable
AWS_ACCOUNT_ID ?= $(or $(shell aws sts get-caller-identity --output text --query "Account" 2 > /dev/null), unknown)

# A counter that represents the build number within GoCD. Used to tag and version our images.
GO_PIPELINE_COUNTER ?= unknown

# VERSION is used to tag the Docker images
VERSION = 0.1.$(GO_PIPELINE_COUNTER)

# ECS related variables used to build our image name
ECS_CLUSTER = ecs
AWS_REGION = eu-west-1

# Tenable.io
TENABLEIO_USER ?= user # passed from an envvar in the CDP
TENABLEIO_PASSWORD ?= password # passed from an envvar in the CDP
TENABLEIO_REGISTRY = cloud.flawcheck.com
TENABLEIO_REPO = web1live
GIT_SHA = $(or $(GO_REVISION), unknown)
GIT_TAG = $(or $(shell git describe --tags --exact-match 2> /dev/null), unknown)
AWS_ACCOUNT ?= unknown

# The name of our Docker image
IMAGE = $(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/$(APP_NAME)

# Container port used for mapping when running our Docker image.
CONTAINER_PORT = 80

# Host port used for mapping when running our Docker image.
HOST_PORT = 80

##
# MAKE TASKS
#   Tasks used locally and within our build pipelines to build, test and run our Docker image.
##

build: # Using the variables defined above, run `docker build`, tagging the image and passing in the required arguments.
	docker build -t $(IMAGE):$(VERSION) -t $(IMAGE):latest \
		--build-arg UTILITIES_BACKEND_IP=$(UTILITIES_BACKEND_IP) \
		--build-arg UTILITIES_BACKEND_PORT=$(UTILITIES_BACKEND_PORT) \
		--build-arg LIST_BACKEND_IP=$(LIST_BACKEND_IP) \
		--build-arg LIST_BACKEND_PORT=$(LIST_BACKEND_PORT) \
		--build-arg THING_BACKEND_IP=$(THING_BACKEND_IP) \
		--build-arg THING_BACKEND_PORT=$(THING_BACKEND_PORT) \
		--build-arg GIT_SHA="$(GIT_SHA)" \
		--build-arg GIT_TAG="$(GIT_TAG)" \
		.

run: # Run the Docker image we have created, mapping the HOST_PORT and CONTAINER_PORT
	docker run --rm -p $(HOST_PORT):$(CONTAINER_PORT) $(IMAGE)

push: # Push the Docker images we have build to the configured Docker repository (Run in GoCD to push the image to AWS)
	docker push $(IMAGE):$(VERSION)
	docker push $(IMAGE):latest

scan-image:
	docker login -u $(TENABLEIO_USER) -p $(TENABLEIO_PASSWORD) $(TENABLEIO_REGISTRY)
	docker tag $(IMAGE):$(VERSION) $(TENABLEIO_REGISTRY)/$(TENABLEIO_REPO)/$(APP_NAME):$(VERSION)
	docker push $(TENABLEIO_REGISTRY)/$(TENABLEIO_REPO)/$(APP_NAME):$(VERSION)

rmi: # Remove local versions of our images.
	docker rmi -f $(IMAGE):$(VERSION)
	docker rmi -f $(IMAGE):latest
	docker rmi $(docker images -a | grep "^<none>" | awk '{print $3}') || true

deploy-ecs: # Deploy our new Docker image onto an AWS cluster (Run in GoCD to deploy to various environments).
	./aws_ecs/register-task-definition.sh $(APP_NAME)
	aws ecs update-service --service $(APP_NAME) --cluster $(ECS_CLUSTER) --region $(AWS_REGION) --task-definition $(APP_NAME)
