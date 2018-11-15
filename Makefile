all:
	make IMAGE=rails_bower tag
	make IMAGE=taa tag

rails_bower: version
	make IMAGE=rails_bower build

taa: version
	make IMAGE=taa build

node: version
	make IMAGE=node build

build:
	for IMAGE in $(IMAGES); do \
		docker build -f Dockerfile.$$IMAGE . -t $$DOCKER_ID_USER/$$IMAGE; \
		if [ $(VERSION) ]; then \
			docker tag $$DOCKER_ID_USER/$$IMAGE $$DOCKER_ID_USER/$$IMAGE:$(VERSION); \
		fi; \
	done

tag:
	for IMAGE in $(IMAGES); do \
		VERSION=$$(cat ./version | grep "^$$IMAGE=" | sed s/$$IMAGE=//g); \
		make IMAGES=$$IMAGE VERSION=$$VERSION build; \
	done

push:
	for IMAGE in $(IMAGES); do \
		VERSION=$$(cat ./version | grep "^$$IMAGE=" | sed s/$$IMAGE=//g); \
		make IMAGES=$$IMAGE tag; \
		docker push $$DOCKER_ID_USER/$$IMAGE; \
		docker push $$DOCKER_ID_USER/$$IMAGE:$$VERSION; \
	done

