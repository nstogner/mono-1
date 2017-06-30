# Mono

The repo contains tooling for managing a mono repo.

The central premise is that a single repo should declaratively describe the
entirety of a project. Terraform is used to provision infrastructure from
configuration files. Kubernetes is used to deploy and run applications in
a declarative manner. Finally, protobufs are used to describe and generate
services. All of these files are stored in a consistent manner inside of a
single repo. The result: an engineer can read through the repo and immediately
understand the state of the project.

Scaffolding is heavily used to reduce the time required to spin up a new project
or api. The `init` command will scaffold the repo directory structure and some
scripts. The `blueprint` command will scaffold out new apis from protobuf
definitions.

It is based on the following tech stack:

- Git (Source Code Management)
- Docker (Application Builds/Environment)
- Kubernetes (Application Deployment/Operations)
- Terraform (Infrastructure Provisioning)
- gRPC (Service Interfaces - Backend)
- REST (Service Interfaces - Frontend)
- Golang (Programming Language)

## Quickstart

#### Prerequisites

*Install:*

- go (https://golang.org/doc/install)
- protoc (https://github.com/google/protobuf/releases)
- docker (https://docs.docker.com/engine/installation)
- terraform (https://www.terraform.io/intro/getting-started/install.html)
- kubectl (https://kubernetes.io/docs/tasks/tools/install-kubectl)
- minikube (https://github.com/kubernetes/minikube)

#### Example

```sh
mkdir repo && cd repo

# Fetch the mono script
wget https://raw.githubusercontent.com/upgear/mono/master/mono.sh && chmod +x mono.sh

# Initialize a mono repo
./mono.sh init

# Mono has created a repo structure
ls
# docker     go         kubernetes mono.sh    protobuf      scripts

# Create a grpc service from the prepopulated protobuf/example.proto definition
./mono.sh bp grpc -s example

# Create a reverse proxy
./mono.sh bp proxy gateway

# Mono scaffolded out go code
tree go/src/internal
# go/src/internal
# ├── example
# │   ├── cmd
# │   │   ├── grpcd
# │   │   │   ├── exampleservice.go
# │   │   │   └── main.go
# │   │   └── httpd
# │   │       └── main.go
# │   ├── example.pb.go
# │   └── example.pb.gw.go
# └── gateway
#     └── cmd
#         └── httpd
#             └── main.go

# Start a local kubernetes cluster
minikube start --kubernetes-version v1.6.4

# Connect docker to minikube
eval $(minikube docker-env)

# Use the scaffolded Dockerfiles to build images
docker build -t blueprint-example -f docker/example.Dockerfile .
docker build -t blueprint-gateway -f docker/gateway.Dockerfile .

# Deploy on kubernetes
kubectl apply -f kubernetes/example.yaml
kubectl apply -f kubernetes/gateway.yaml

# Test the endpoint
curl $(minikube service gateway --url)/example/echo -X POST -d '{}' -v

```
