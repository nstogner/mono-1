#!/bin/bash

this_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

usage ()
{
    echo "Usage: $0 [subcommand]"
    echo
    echo "Subcommands:"
    echo "  help"
    echo "  init       Setup mono-repo"
    echo "  blueprint  Run blueprint"
    exit 1
}

scaffoldTerraform() {
cat >terraform/gcloud.tf << EOL
// Configure the Google Cloud provider
provider "google" {
  project     = "YOUR_PROJECT"
  region      = "us-central1"
}

resource "google_container_cluster" "primary" {
  name               = "mono-cluster"
  zone               = "us-central1-a"
  initial_node_count = 3

  additional_zones = []

  node_config {
    machine_type = "f1-micro"
    disk_size_gb = 10
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/sqlservice",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
EOL
}

runInit() {
    git init
    export GOPATH=$this_dir/go
    mkdir {go,scripts,kubernetes,terraform,protobuf,docker}
    echo "bin/" >> go/.gitignore
    echo "pkg/" >> go/.gitignore

    scaffoldTerraform

    git clone https://github.com/upgear/blueprint scripts/blueprint
    rm -rf scripts/blueprint/.git
    cp scripts/blueprint/example.proto protobuf
}

subcmd=$1
shift
case $subcmd in
    help)
        usage
        ;;
    init)
        runInit
        ;;
    blueprint)
        repo=$(git rev-parse --show-toplevel)

        #export BP_DOCKER_IMAGE=gcr.io/YOUR_GCLOUD_PROJECT_HERE/masterkube
        export BP_PROTO_DIR=$repo/protobuf
        export BP_KUBE_DIR=$repo/kubernetes
        export BP_DOCKER_DIR=$repo/docker
        export GOPATH=$repo/go

        export BP_OUTPUT_DIR=$repo/go/src/internal
        source $this_dir/scripts/blueprint/blueprint.sh $@
        ;;
    *)
        echo "Invalid subcommand: $subcmd" >&2
        usage
        ;;
esac

