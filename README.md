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

This can save space as long as 2 different projects share the common layers

This can also speed up tests on CI or deployments, as tests will have 0 or just a few
seconds for installing dependencies, so will building production images which can
rely on the base images.

Release can also be accelerated as only the last changed layer is pushed to a server.

## Images Categories
The project has 3 categories of images
- Regular images: Images used in development or as a suport tool
- Circleci images: Images optimized to run on CI (circleci) with extra testing / building tools
- Production images: Images without develpment dependencies designed to
  be lightweight and run in servers
