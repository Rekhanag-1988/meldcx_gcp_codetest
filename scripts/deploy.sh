#!/bin/bash

set -o errexit
set -o pipefail

usage () { echo -e "Usage:\n$0 --website-folder [local-relative-path] --project [gcp-project] --zone [preferred-zone]" 1>&2 ; exit 1; }

function parse_args {

	while getopts "\-:" opt ; do
		case "${opt}" in
			-)
				case "${OPTARG}" in
					website-folder)
						website_folder="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
						[ ! -d "${PWD}/${website_folder}" ] && {
							echo "Local path: ${website_folder} is not found. Provide an absolute path" >&2
							exit 1
						}
					;;
					project)
						project="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
					;;
					zone)
						zone="${!OPTIND}"; OPTIND=$(( $OPTIND + 1 ))
					;;
					help)
						usage
						exit 1
					;;
					*)
						echo "Unknown option: $OPTARG supplied." >&2
						usage
				esac
			;;
			*)
				echo "Unknown option: $OPTARG supplied." >&2
				usage
			;;
		esac
	done

	shift $((OPTIND-1))
}

function update_application {

	echo -e "\n>>> Updating application container image."
	echo ">>> Copying static-content from ${website_folder} to build-server:codetest-cicd-vm:/codetest directory."
	gcloud compute scp --recurse  ${PWD}/${website_folder} codetest-cicd-vm:/codetest

	app_tag=$(cat ${website_folder}/metadata.json|jq --raw-output '.version' )
	echo ">>> Invoking image/build-deploy cycle for the container with tag:${app_tag} as specified in metadata.json."
	echo -e ">>> We will be deleting old images on the build-server:codetest-cicd-vm and on webserver:codetest-application-vm(Pending implementation)\n"

	gcloud compute ssh codetest-cicd-vm \
		--command="cd /codetest/app_src;make deploy_image project=${project} app_tag=${app_tag} zone=${zone}"

}

function main {
	
	if [ -z "$3" ]; then
		echo -e "Script needs atleast three arguments"
		usage
	fi

	parse_args "$@"

	gcloud config set project ${project}
	gcloud config set compute/zone ${zone}

	update_application



}

main $@