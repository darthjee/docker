rails_bower:
	docker IMAGE=rails_bower build

taa:
	docker IMAGE=taa build

build:
	docker build -f Dockerfile.$(IMAGE) . -t $$DOCKER_ID_USER/$(IMAGE)

push:
	make build
	docker push $$DOCKER_ID_USER/$(IMAGE)
