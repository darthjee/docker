rails_bower:
	make IMAGE=rails_bower build

taa: rails_bower
	make IMAGE=taa build

build:
	docker build -f Dockerfile.$(IMAGE) . -t $$DOCKER_ID_USER/$(IMAGE)

push:
	VERSION=$$(cat ./version | grep '$(IMAGE)=' | sed s/$(IMAGE)=//g); \
	make $(IMAGE); \
	docker tag $$DOCKER_ID_USER/$(IMAGE) $$DOCKER_ID_USER/$(IMAGE):$$VERSION; \
	docker push $$DOCKER_ID_USER/$(IMAGE); \
	docker push $$DOCKER_ID_USER/$(IMAGE):$$VERSION

