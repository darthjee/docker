DOCKER_ID_USER?=docker_test
IMAGE=$(DOCKER_ID_USER)/override

build: file.txt Dockerfile.*
	INITIAL_SIZE=$$(df /etc/docker/ | grep "/" | sed -e "s/^\([^ ]* *\)\{3\}//" | sed -e "s/ .*//"); \
	docker build . -f Dockerfile.1 -t $(IMAGE):1; \
	docker build . -f Dockerfile.2 -t $(IMAGE):2 --build-arg IMAGE=$(IMAGE); \
	docker build . -f Dockerfile.3 -t $(IMAGE):3 --build-arg IMAGE=$(IMAGE); \
	FINAL_SIZE=$$(df /etc/docker/ | grep "/" | sed -e "s/^\([^ ]* *\)\{3\}//" | sed -e "s/ .*//"); \
	DIFF_SIZE=$$[$$INITIAL_SIZE-$$FINAL_SIZE]; \
	echo "Build size: $$DIFF_SIZE"

file.txt:
	dd if=/dev/urandom of=file.txt bs=1048576 count=1024
