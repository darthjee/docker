DOCKER_ID_USER?=docker_test
IMAGE=$(DOCKER_ID_USER)/override

build: file.txt
	docker build . -f Dockerfile.1 -t $(IMAGE):1

file.txt:
	dd if=/dev/urandom of=file.txt bs=1048576 count=1024
