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
		docker tag $$DOCKER_ID_USER/$$IMAGE:latest $$DOCKER_ID_USER/$$IMAGE:cached; \
		docker rmi $$DOCKER_ID_USER/$$IMAGE:latest; \
		docker pull $$DOCKER_ID_USER/$$IMAGE:latest; \
		VERSION=$$(cat ./version | grep "^$$IMAGE=" | sed s/$$IMAGE=//g); \
		docker build -f $$IMAGE/$$VERSION/Dockerfile $$IMAGE/$$VERSION/ -t $$DOCKER_ID_USER/$$IMAGE; \
		if [ $(VERSION) ]; then \
			docker tag $$DOCKER_ID_USER/$$IMAGE $$DOCKER_ID_USER/$$IMAGE:$(VERSION); \
		fi; \
		if (docker images | grep $$DOCKER_ID_USER/$$IMAGE | grep cached); then \
		  docker rmi $$DOCKER_ID_USER/$$IMAGE:cached; \
		fi \
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

test:
	for IMAGE in $(IMAGES); do \
		VERSION=$$(cat ./version | grep "^$$IMAGE=" | sed s/$$IMAGE=//g); \
		USER_NAME=$${IMAGE%%_*}; \
		USER_NAME=$$(echo $$USER_NAME | grep circleci || echo app); \
	  DOCKER_ID_USER=$$DOCKER_ID_USER IMAGE=$$IMAGE VERSION=$$VERSION \
		USER_NAME=$$USER_NAME \
		IMAGE_NAME=$$IMAGE"_test"  docker-compose \
	    -f docker-compose-test.yml \
			run test; \
	done
