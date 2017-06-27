# Mono

The repo contains tooling for managing a mono repo. It is based on the following
tech stack:

- Git
- Docker
- Kubernetes
- gRPC
- REST (via gRPC gateway)
- Golang (+ more later)

## Quickstart

#### Prerequisites

*Install:*

- go (https://golang.org/doc/install)
- protoc (https://github.com/google/protobuf/releases)
- docker (https://docs.docker.com/engine/installation)
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
