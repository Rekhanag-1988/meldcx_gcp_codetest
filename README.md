# MeldCX Codetest Solution Repository

## Overview
This repository contains solution of meldCx gcp-codetest solution using gcloud SDK and Deployment Manager.

## Working Model Demo Video

[MeldCX Codetest](https://www.youtube.com/watch?v=80aPohgzgd0)

## Repo Layout
>### [app_src](./app_src)
>Webserver static content directory and other configuration settings.
>>#### [static_content](./app_src/static_content)
>>Webserver static html and image files.
>>#### [Dockerfile](./app_src/Dockerfile)
>>Simple Dockerfile configuration to copy the above static content to stable nginx-docker-image and build custom image.
>>#### [metadata.json](./app_src/metadata.json)
>>File to commit and review application docker image version from source repository.
>>#### [Makefile](./app_src/Makefile)
>>List of make rules which will be executed on the CICD-Build server as part of build-deploy cycle.

>### [infra](./infra) 
>Holds Deployment manager Jinja templates and related configurations
>>##### [jinja](./infra/jinja)
>>Single Jinja template which can be used for creating both application network and cicd network
>>##### [scribbles](./infra/scribbles)
>>Hand drawn architecture diagram for better illustration.
>>##### [app_container_spec](./infra/app_container_spec.yaml)
>>Container specifications to be used during instance creation for webserver. We are using compute engines with containers.
>>##### [app_network](./infra/app_network.yaml)
>>Properties for application network and resources.
>>##### [cicd_network](./infra/cicd_network.yaml)
>>Properties for cicd network and resources.

>### [scripts](./scripts)
>Basic orchestrator scripts.
>>##### [prepare.sh](./scripts/prepare.sh)
>>Takes project-name and zone as input parameters and creates/updates application-network and cicd-network resources.
>>##### [deploy.sh](./scripts/deploy.sh)
>>Deploys provided local static content on to application-vm-container by running Make-rules remotely on CICD-server.
>>##### [cleanup.sh](./scripts/cleanup.sh)
>>Nukes every thing out.

## Runsheet:

Make sure your local e

## How to Deploy works?

We have created webserver compute engine with gce-container-declaration metadata. This makes a container with the [provided-spec](./infra/app_container_spec.yaml) start during compute engine startup.

Deployment has the below steps:
* `gcloud compute scp` Transfers local static content and other files to cicd-vm-container.
* `gcloud compute ssh` Execute commands [Makefile-rules](./app_src/Makefile) on remote cicd-vm-container.
* `docker build, tag, publish` Build and publish the image with tag specified [here](./app_src/metadata.json)
* `gcloud compute instances update-container` Execute this command as a Make-Rule from cicd-vm-container to update the image on app-vm-container.
* Prunes old images.

## POINTS TO REMEMBER

:point_right: Have copied stable nginx docker image to Google container registry.\
:point_right: Configured Cloud-NAT-Gateway so that build server can download and install packages if needed from internet.\
:point_right: Old images are getting deleted from build server.But could not able to delete them on application-vm. Have to implement VPC-Peering for this.\

