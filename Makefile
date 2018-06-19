rails_bower:
	docker IMAGE=rails_bower build

taa:
	docker IMAGE=taa build

build:
	docker build -f Dockerfile.$(IMAGE) . -t $(IMAGE)

push:
	make build
	docker tag $(IMAGE) $$DOCKER_ID_USER/$(IMAGE)
	docker push $$DOCKER_ID_USER/$(IMAGE)
