#!/bin/bash

set -o errexit
set -o pipefail

usage () { echo -e "Usage:\n$0 --project-name [gcp-project] --zone [preferred-zone]" 1>&2 ; exit 1; }

function parse_args {

	while getopts "\-:" opt ; do
		case "${opt}" in
			-)
				case "${OPTARG}" in
					project-name)
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
						echo ">>> Unknown option: $OPTARG supplied." >&2
						usage
				esac
			;;
			*)
				echo ">>> Unknown option: $OPTARG supplied." >&2
				usage
			;;
		esac
	done

	shift $((OPTIND-1))
}

function clean_gcr {

	echo ">>> Cleaning up the container registry images gcr.io/${project}/rekhanag_cv"
	all_image_digets=$(gcloud container images list-tags gcr.io/${project}/rekhanag_cv \
		--filter='tags:*' \
		--format="get(digest)")
	if [ -n ${all_image_digets} ]; then
		echo ">>> Deleting all_image_digets"
		gcloud container images delete gcr.io/${project}/rekhanag_cv@${all_image_digets} \
			--force-delete-tags \
			--quiet
	else
		echo ">>> Specified image gcr.io/${project}/rekhanag_cv does not exist. We cant delete it."
	fi

}

function delete_network {
	network_tag=$1
	echo -e "\n>>> Deleting codetest-${network_tag}-network and related resources"
	dep_name=$(gcloud deployment-manager deployments list \
		--filter="name=codetest-${network_tag}-network" \
		--format="json" | jq -r '.[].name')
	if [ -n ${dep_name} ]; then
		echo ">>> Deployment: ${dep_name} exists. Deleting it."
		gcloud deployment-manager deployments delete codetest-${network_tag}-network --quiet
	else
		echo ">>> Provide deployment: codetest-${network_tag}-network does not exists. Hence, we cant delete it"
	fi

}

function main {
	
	if [ -z "$2" ]; then
		echo -e ">>> Script needs atleast two arguments"
		usage
	fi

	parse_args "$@"

	gcloud config set project ${project}
	gcloud config set compute/zone ${zone}

	delete_network "app"
	delete_network "cicd"

	clean_gcr

}

main $@