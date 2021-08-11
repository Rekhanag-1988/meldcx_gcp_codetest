#!/usr/bin/env make

.DEFAULT_GOAL := help

app_image ?= gcr.io/${project}/rekhanag_cv:${app_tag}

prune_old_images_on_buildserver:: ## Deleting old application images, to have image-always-pull policy
	@echo ">>> Deleting old images."
	@echo ${app_image}
	@-sudo docker rmi --force $$(sudo docker images --filter "label=image_name=codetest") 2>/dev/null

build_image:: prune_old_images_on_buildserver ## Builds application image by copying the static content.
	@echo ">>> Building application image with tag: ${app_image}"
	@sudo docker build --tag ${app_image} .

registry_auth:: ## Docker authentication to GCR
	@gcloud auth configure-docker --quiet

publish_image:: build_image registry_auth ## Publishes application image to Google Container Registry.
	@sudo docker push ${app_image}

deploy_image:: publish_image
	@gcloud compute instances update-container codetest-application-vm \
		--container-image ${app_image} \
		--zone ${zone}

# Need to implement VPC-Tunneling between application and cicd networks to make this rule work.
prune_old_images_on_webserver:: ##Deleting old application images
	@gcloud compute ssh codetest-application-vm --zone ${zone} --command 'sudo docker rmi --force $(sudo docker images --filter "before=${app_image}") 2>/dev/null'
	
help: ## Help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)