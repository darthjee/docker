DOCKER_ID_USER?=docker_test

build: Dockerfile*
	for FILE in  Dockerfile.*; do \
		NAME=$${FILE##Dockerfile.}; \
		IMAGE=$(DOCKER_ID_USER)/$$NAME; \
	  docker build . -f $$FILE -t $$IMAGE; \
	done
