# darthjee/docker:0.1.0

This image is based on Alpine and includes the Docker CLI, making it suitable for running Docker commands inside containers (Docker-in-Docker scenarios). In addition, it comes with a custom script (`docker_hub.sh`) that simplifies working with Docker Hub, including logging in, pushing images, and updating repository descriptions.

## Features
- Based on Alpine for a minimal footprint
- Includes Docker CLI (from `docker:29.2.0-rc.1-cli-alpine3.23`)
- Adds a non-root user (`app`) for safer container execution
- Provides a helper script (`docker_hub.sh`) to:
  - Log in to Docker Hub using environment variables
  - Push images to Docker Hub
  - Update the full description of a Docker Hub repository

## Usage

Mount your Docker socket and set the required environment variables to use the helper script:

```
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e DOCKER_HUB_USERNAME=your_username \
  -e DOCKER_HUB_PASSWORD=your_password \
  darthjee/docker:0.1.0 docker_hub.sh login
```

See the script at `/usr/local/sbin/docker_hub.sh` for available actions: `login`, `push`, and `push_description`.

## Example: Push an image and update description

```
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e DOCKER_HUB_USERNAME=your_username \
  -e DOCKER_HUB_PASSWORD=your_password \
  -v $(pwd)/README.md:/tmp/desc.md \
  darthjee/docker:0.1.0 sh -c "docker_hub.sh login && docker_hub.sh push yourrepo/image:tag && docker_hub.sh push_description yourrepo/image /tmp/desc.md"
```

## License
See LICENSE file for details.
