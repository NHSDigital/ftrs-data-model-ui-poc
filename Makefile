# This file is for you! Edit it to implement your own hooks (make targets) into
# the project as automated steps to be executed on locally and in the CD pipeline.

include scripts/init.mk

# ==============================================================================
LAMBDA_NAME := ${REPO_NAME}-lambda
LAYER_NAME := ${REPO_NAME}-layer
S3_BUCKET := ${REPO_NAME}-$(ENVIRNOMENT)-artefacts-bucket
BUILD_DIR := build
SRC_DIR := src
REQUIREMENTS := $(SRC_DIR)/requirements.txt
ZIP_FILE := $(BUILD_DIR)/$(LAMBDA_NAME).zip

# Example CI/CD targets are: dependencies, build, publish, deploy, clean, etc.

dependencies: # Install dependencies needed to build and test the project @Pipeline
	# TODO: Implement installation of your project dependencies

build: build-layer build-package # Build the project artefact

build-layer: clean
	mkdir -p $(BUILD_DIR)/layer/python
	python -m pip install -r $(REQUIREMENTS) -t $(BUILD_DIR)/layer/python
	cd $(BUILD_DIR)/layer && zip -r ../$(LAYER_NAME).zip python

build-package: clean build-layer
	mkdir -p $(BUILD_DIR)/package
	cp -r $(SRC_DIR)/* $(BUILD_DIR)/package
	cp $(BUILD_DIR)/$(LAYER_NAME).zip $(BUILD_DIR)/package
	cd $(BUILD_DIR)/package && zip -r ../$(LAMBDA_NAME).zip .

publish: # Publish the project artefact @Pipeline
	aws s3 cp $(BUILD_DIR)/$(LAMBDA_NAME).zip s3://$(S3_BUCKET)/$(LAMBDA_NAME)/$(LAMBDA_NAME)-$(COMMIT_HASH).zip --region $(AWS_REGION)
	aws s3 cp $(BUILD_DIR)/$(LAYER_NAME).zip s3://$(S3_BUCKET)/$(LAYER_NAME)/$(LAYER_NAME)-$(COMMIT_HASH).zip --region $(AWS_REGION)

deploy: # Deploy the project artefact to the target environment @Pipeline
	# TODO: Implement the artefact deployment step

clean:: # Clean-up project resources (main) @Operations
	rm -rf $(BUILD_DIR)

config:: # Configure development environment (main) @Configuration
	# TODO: Use only 'make' targets that are specific to this project, e.g. you may not need to install Node.js
	make _install-dependencies

# ==============================================================================

${VERBOSE}.SILENT: \
	build \
	clean \
	config \
	dependencies \
	deploy \
