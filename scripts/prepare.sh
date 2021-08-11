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

function create_update_network {
	network_tag=$1
	echo -e "\n>>> Deploying codetest-${network_tag}-network and related resources"
	# Decision on whether to update or create a deployment.
	dep_name=$(gcloud deployment-manager deployments list --filter="name=codetest-${network_tag}-network" --format="json" | jq -r '.[].name')
	if [ ! -z ${dep_name} ]; then
		echo ">>> Deployment: ${dep_name} exists. Updating it."
		gcloud deployment-manager deployments update codetest-${network_tag}-network \
		--config infra/${network_tag}_network.yaml
	else
		echo ">>> Creating Deployment: codetest-${network_tag}-network."
		gcloud deployment-manager deployments create codetest-${network_tag}-network \
			--config infra/${network_tag}_network.yaml --automatic-rollback-on-error
	fi

	elb_ip=$(gcloud compute forwarding-rules list \
			--filter="name ~ codetest"	\
			--format="json" | jq  -r '.[].IPAddress')
	echo ">>> Your application is running on http://${elb_ip}/"

}

function main {
	
	if [ -z "$2" ]; then
		echo -e ">>> Script needs atleast two arguments"
		usage
	fi

	parse_args "$@"

	gcloud config set project ${project}
	gcloud config set compute/zone ${zone}

	create_update_network "app"
	create_update_network "cicd"

}

main $@