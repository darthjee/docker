Docker
======

This project has build base images for serveral projects

## Motivation

Many projects have oftenly share the same docker setup or dependencies, so
a good repository for all Dockerfiles is needed.

At the same time projects cannot have just a huge docker image with all the dependencies
any project can have, so there are images for each project purpose, still, space usage
can be kept to a minimum by taking advantage of Docker layering

### Docker images and layers

Docker images store a layer for each command so that any image built on top, only the
new layers / commands needs to stored and when a container needs to be initialized,
the layers are collected and assembled

![layers](https://raw.githubusercontent.com/darthjee/docker/master/docker_setup.gif)
