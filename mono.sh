#!/bin/bash

this_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

usage ()
{
    echo "Usage: $0 [subcommand]"
    echo
    echo "Subcommands:"
    echo "  help"
    echo "  init  Setup mono-repo"
    echo "  bp    Run blueprint"
    exit 1
}

runInit() {
    if [ -f $this_dir/mono.env ]; then
        (>&2 echo "mono.env exists: looks like this repo has already been setup")
        exit 1
    fi

    git init
    export GOPATH=$this_dir/go
    mkdir $this_dir/{go,scripts,kubernetes,protobuf,docker}

    echo "bin/" >> $this_dir/go/.gitignore
    echo "pkg/" >> $this_dir/go/.gitignore

    git clone https://github.com/upgear/blueprint $this_dir/scripts/blueprint
    cp $this_dir/scripts/blueprint/example.proto protobuf
}

# Enforce dependencies
must_be_a_thing() {
    if ! type "$1" > /dev/null; then
        (>&2 echo "install $1 in your PATH before continuing $2")
        exit 1
    fi
}
must_be_a_thing go '(https://golang.org/doc/install)'

subcmd=$1
shift
case $subcmd in
    help)
        usage
        ;;
    init)
        runInit
        ;;
    bp)
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

