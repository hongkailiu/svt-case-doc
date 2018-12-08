# [Protocol Buffers](https://developers.google.com/protocol-buffers/)

## Doc

* [Developer Guide](https://developers.google.com/protocol-buffers/docs/overview)
* [Protocol Buffer Language Guide](https://developers.google.com/protocol-buffers/docs/proto)
* [k8s api server can be communicated via pb](https://kubernetes.io/docs/concepts/overview/kubernetes-api/#openapi-and-swagger-definitions): [some .proto file in k8s repo](https://github.com/kubernetes/kubernetes/blob/master/pkg/kubelet/apis/cri/runtime/v1alpha2/api.proto)

## [golang with protocol buffer 3](https://developers.google.com/protocol-buffers/docs/gotutorial)

Test repo: [proto_buffer](https://github.com/hongkailiu/test-go/tree/master/proto_buffer).

```bash
### tested on fedora 26
### define your pb messages:
$ ll proto_buffer/proto/
total 2
-rw-rw-r--. 1 hongkliu hongkliu 523 Oct 29 15:47 addressbook.proto

### download pb
$ curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v3.6.1/protoc-3.6.1-linux-x86_64.zip
$ unzip protoc-3.6.1-linux-x86_64.zip -d pb
$ cd pb

### include the binary in your ${PATH}
$ cd ~/bin/
$ ln -s ../pb/bin/protoc protoc

### download pb golang plugin
$ go get -u github.com/golang/protobuf/protoc-gen-go
$ which protoc-gen-go
~/go/bin/protoc-gen-go

$ go get github.com/hongkailiu/test-go
$ cd $GOPATH/src/github.com/hongkailiu/test-go
$ mkdir -p ./probuf/gen
$ protoc -I=./probuf/ --go_out=./probuf/gen ./probuf/proto/addressbook.proto
$ tree ./proto_buffer/gen/
./proto_buffer/gen/
└── proto
    └── addressbook.pb.go

## Then see how to use the generated code in the unit tests
$ make test-pb
```


## Use pb to transfer data

### [gRPG](https://grpc.io/docs/tutorials/basic/go.html)

Add service definition into addressbook.proto, and then

```bash
### Update the generated code
$ protoc -I=./pkg/probuf/  --plugin=protoc-gen-grpc --go_out=plugins=grpc:./pkg/probuf/gen ./pkg/probuf/proto/addressbook.proto

### Use it in server/client code, and run:
$ go run ./pkg/grpc/helloworld/server/main.go

### User another terminal
$ go run ./pkg/grpc/helloworld/client/main.go 67
2018/12/08 00:57:55 Person: name:"John Doe" id:67 email:"jdoe@example.com" phones:<number:"555-4321" type:HOME > 

``` 


Troubleshooting

```bash
### undefined: unix.GetsockoptLinger
### https://github.com/grpc/grpc-go/issues/2181#issuecomment-414324934

$ vi glide.yaml

- name: golang.org/x/sys
  version: 1c9583448a9c3aa0f9a6a5241bf73c0bd8aafded
  subpackages:

### undefined: proto.ProtoPackageIsVersion3
### https://github.com/golang/protobuf/issues/763#issuecomment-443760051
$ go test -v ./pkg/probuf/...
# github.com/hongkailiu/test-go/pkg/probuf/gen/proto
pkg/probuf/gen/proto/addressbook.pb.go:24:11: undefined: proto.ProtoPackageIsVersion3
FAIL    github.com/hongkailiu/test-go/pkg/probuf/unittest [build failed]

$ cd $GOPATH/src/github.com/golang/protobuf/protoc-gen-go
$ git checkout v1.2.0
$ go install

```

TODO: See how the [test in the example](https://github.com/grpc/grpc-go/blob/master/examples/helloworld/mock_helloworld/hw_mock_test.go) is done with [gomock](https://github.com/golang/mock). 

## How pb is used in k8s implementation
TODO
