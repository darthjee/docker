rails_bower:
	docker IMAGE=rails_bower build

build:
	docker build -f Dockerfile.$(IMAGE) . -t $(IMAGE)

push:
	build
	docker tag $(IMAGE) $$DOCKER_ID_USER/$(IMAGE)
	docker push $$DOCKER_ID_USER/$(IMAGE)
