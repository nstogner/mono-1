# Mono

The repo contains tooling for managing a mono repo. It is based on the following
tech stack:

- Git
- Docker
- Kubernetes
- gRPC
- REST (via gRPC gateway)
- Golang (+ more later)

```sh
$ mkdir repo && cd repo

# Fetch the mono script
$ wget https://raw.githubusercontent.com/upgear/mono/master/mono.sh && chmod +x mono.sh

# Initialize a mono repo
$ ./mono.sh init

# Mono has created a repo structure
$ ls
docker     go         kubernetes mono.sh    protobuf

# Create a grpc service from the prepopulated protobuf/example.proto definition
$ ./mono.sh bp grpc -s example

# Mono scaffolded out a working service
$ tree go/src/internal
go/src/internal
└── example
    ├── cmd
    │   ├── grpcd
    │   │   ├── exampleservice.go
    │   │   └── main.go
    │   └── httpd
    │       └── main.go
    ├── example.pb.go
    └── example.pb.gw.go

4 directories, 5 files

# Use the scaffolded Dockerfile to build an image
$ docker build -f docker/example.Dockerfile .
Sending build context to Docker daemon 116.2 MB
Step 1/4 : FROM golang:1.8
 ---> d2f558dda133
Step 2/4 : ADD ./go/src /go/src
 ---> 1d813681d113
Removing intermediate container 7a884c7b3e0f
Step 3/4 : RUN go install internal/example/cmd/httpd
 ---> Running in 352edc3eeeb1
 ---> d79fbefaa92d
Removing intermediate container 352edc3eeeb1
Step 4/4 : RUN go install internal/example/cmd/grpcd
 ---> Running in 3219b19436cd
 ---> efa285ce1c56
Removing intermediate container 3219b19436cd
Successfully built efa285ce1c56

# TODO: Show kubernetes example

```
