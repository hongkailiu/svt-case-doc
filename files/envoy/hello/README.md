# envoy-hello-world

build-images

```bash
$ svt-case-doc/files/envoy/hello
$ buildah bud --format=docker -f ./Dockerfile.service.txt -t docker.io/hongkailiu/test-envoy:service-001 .
$ buildah push --creds=hongkailiu 6a00cb13c37f docker://docker.io/hongkailiu/test-envoy:service-001

```