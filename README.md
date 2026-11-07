Docker
======

![docker](https://raw.githubusercontent.com/darthjee/docker/master/docker.png)

[![Codacy Badge](https://app.codacy.com/project/badge/Grade/c7cc9a38259d405084aada297796684f)](https://app.codacy.com/gh/darthjee/docker/dashboard?utm_source=gh&utm_medium=referral&utm_content=&utm_campaign=Badge_grade)


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

![layers](https://raw.githubusercontent.com/darthjee/docker/master/readme_files/docker_setup.gif)

This can save space as long as 2 different projects share the common layers

This can also speed up tests on CI or deployments, as tests will have 0 or just a few
seconds for installing dependencies.

- Regular build

  ![slow build](https://raw.githubusercontent.com/darthjee/docker/master/readme_files/slow_build.png)

- Improoved build

  ![fast build](https://raw.githubusercontent.com/darthjee/docker/master/readme_files/speed_build.png)

Release can also be accelerated as only the last changed layer is built and pushed to a server which already
contains the same base.

![fast release flow](https://raw.githubusercontent.com/darthjee/docker/master/readme_files/build-push.gif)

- Regular release

  ![slow release](https://raw.githubusercontent.com/darthjee/docker/master/readme_files/slow_build_release.png)

- Improoved release

  ![fast release](https://raw.githubusercontent.com/darthjee/docker/master/readme_files/fast_build_release.png)

## Images Categories

The project has 4 categories of images
- Tool images: Images used as tools that have no circleci or production counter-parts
- Dev images: Images used in development which will then have a circleci and production counterpart
- Circleci images: Images optimized to run on CI (circleci) with extra testing / building tools
- Production images: Images without develpment dependencies designed to
  be lightweight and run in servers

## Multi-Stage build

Since a lot of dependency instalations generate extra garbage (source files, logs, etc)
a multi stage build can use an image for all the compilation, instalations and configurations
having the final result being copied to a final image which will then be released.

And added advantage is the this generates single layers for a lot of joint instalation commands
and, even though this can be an anti-pattern, this can reduce the layer count, specially when we
talk about images that rely on a base image already containing a lot of layers as some services
have a maximum layer limit (40 for Heroku).

Multi-Stage build add an extra hassle that when trying to rebuild the image, if the intermediate
build image has been deleted, the docker cachec cannot find it, so it has to rebuild it, but
the added base image advantages can overcome this problem.

### Dangers and pitfalls

Docker does not have a concept of deleting or updating a file, so such actions generate new layers
which store the file again

![overwritte](https://raw.githubusercontent.com/darthjee/docker/master/readme_files/overwritte.png)

This is specially dangerous when building using multistage as files are copied from the build stage
image into the final image, so a check of which files are new and which already existed is needed
and this is done based on the type of dependency (npm files, ruby gems, etc)

## script image

Sometimes, script files must be shared by images which do not share a base, and sometimes those
scripts are only used in the build stage of a docker build, so an image was created to be a
script repository where scripts are copied from during docker build.

## Images

#### Tools
  - [![docker](https://img.shields.io/docker/v/darthjee/scripts.svg?logo=docker&label=scripts&sort=semver)](https://hub.docker.com/r/darthjee/scripts)
### Development
  - [![docker](https://img.shields.io/docker/v/darthjee/node.svg?logo=docker&label=node&sort=semver)](https://hub.docker.com/r/darthjee/node)
  - [![docker](https://img.shields.io/docker/v/darthjee/node_mongo.svg?logo=docker&label=node_mongo&sort=semver)](https://hub.docker.com/r/darthjee/node_mongo)
  - [![docker](https://img.shields.io/docker/v/darthjee/python.svg?logo=docker&label=python&sort=semver)](https://hub.docker.com/r/darthjee/python)
  - [![docker](https://img.shields.io/docker/v/darthjee/python_37.svg?logo=docker&label=python_37&sort=semver)](https://hub.docker.com/r/darthjee/python_37) (deprecated, use `python`)
  - [![docker](https://img.shields.io/docker/v/darthjee/rails_bower.svg?logo=docker&label=rails_bower&sort=semver)](https://hub.docker.com/r/darthjee/rails_bower)
  - [![docker](https://img.shields.io/docker/v/darthjee/rails_yarn.svg?logo=docker&label=rails_yarn&sort=semver)](https://hub.docker.com/r/darthjee/rails_yarn)
  - [![docker](https://img.shields.io/docker/v/darthjee/rails_gems.svg?logo=docker&label=rails_gems&sort=semver)](https://hub.docker.com/r/darthjee/rails_gems)
  - [![docker](https://img.shields.io/docker/v/darthjee/ruby_331.svg?logo=docker&label=ruby_331&sort=semver)](https://hub.docker.com/r/darthjee/ruby_331)
  - [![docker](https://img.shields.io/docker/v/darthjee/ruby_3412.svg?logo=docker&label=ruby_3412&sort=semver)](https://hub.docker.com/r/darthjee/ruby_3412)
  - [![docker](https://img.shields.io/docker/v/darthjee/ruby_node.svg?logo=docker&label=ruby_node&sort=semver)](https://hub.docker.com/r/darthjee/ruby_node)
  - [![docker](https://img.shields.io/docker/v/darthjee/taa.svg?logo=docker&label=taa&sort=semver)](https://hub.docker.com/r/darthjee/taa)
  - [![docker](https://img.shields.io/docker/v/darthjee/taap.svg?logo=docker&label=taap&sort=semver)](https://hub.docker.com/r/darthjee/taap)
  - [![docker](https://img.shields.io/docker/v/darthjee/django.svg?logo=docker&label=django&sort=semver)](https://hub.docker.com/r/darthjee/django)
### Circleci
  - [![docker](https://img.shields.io/docker/v/darthjee/circleci_node.svg?logo=docker&label=circleci_node&sort=semver)](https://hub.docker.com/r/darthjee/circleci_node)
  - [![docker](https://img.shields.io/docker/v/darthjee/circleci_node_mongo.svg?logo=docker&label=circleci_node_mongo&sort=semver)](https://hub.docker.com/r/darthjee/circleci_node_mongo)
  - [![docker](https://img.shields.io/docker/v/darthjee/circleci_python.svg?logo=docker&label=circleci_python&sort=semver)](https://hub.docker.com/r/darthjee/circleci_python)
  - [![docker](https://img.shields.io/docker/v/darthjee/circleci_python_37.svg?logo=docker&label=circleci_python_37&sort=semver)](https://hub.docker.com/r/darthjee/circleci_python_37) (deprecated, use `circleci_python`)
  - [![docker](https://img.shields.io/docker/v/darthjee/circleci_rails_bower.svg?logo=docker&label=circleci_rails_bower&sort=semver)](https://hub.docker.com/r/darthjee/circleci_rails_bower)
  - [![docker](https://img.shields.io/docker/v/darthjee/circleci_rails_yarn.svg?logo=docker&label=circleci_rails_yarn&sort=semver)](https://hub.docker.com/r/darthjee/circleci_rails_yarn)
  - [![docker](https://img.shields.io/docker/v/darthjee/circleci_rails_gems.svg?logo=docker&label=circleci_rails_gems&sort=semver)](https://hub.docker.com/r/darthjee/circleci_rails_gems)
  - [![docker](https://img.shields.io/docker/v/darthjee/circleci_ruby_331.svg?logo=docker&label=circleci_ruby_331&sort=semver)](https://hub.docker.com/r/darthjee/circleci_ruby_331)
  - [![docker](https://img.shields.io/docker/v/darthjee/circleci_ruby_3412.svg?logo=docker&label=circleci_ruby_3412&sort=semver)](https://hub.docker.com/r/darthjee/circleci_ruby_3412)
  - [![docker](https://img.shields.io/docker/v/darthjee/circleci_ruby_node.svg?logo=docker&label=circleci_ruby_node&sort=semver)](https://hub.docker.com/r/darthjee/circleci_ruby_node)
  - [![docker](https://img.shields.io/docker/v/darthjee/circleci_taa.svg?logo=docker&label=circleci_taa&sort=semver)](https://hub.docker.com/r/darthjee/circleci_taa)
  - [![docker](https://img.shields.io/docker/v/darthjee/circleci_taap.svg?logo=docker&label=circleci_taap&sort=semver)](https://hub.docker.com/r/darthjee/circleci_taap)
  - [![docker](https://img.shields.io/docker/v/darthjee/circleci_django.svg?logo=docker&label=circleci_django&sort=semver)](https://hub.docker.com/r/darthjee/circleci_django)
### Production
  - [![docker](https://img.shields.io/docker/v/darthjee/production_rails_bower.svg?logo=docker&label=production_rails_bower&sort=semver)](https://hub.docker.com/r/darthjee/production_rails_bower)
  - [![docker](https://img.shields.io/docker/v/darthjee/production_rails_yarn.svg?logo=docker&label=production_rails_yarn&sort=semver)](https://hub.docker.com/r/darthjee/production_rails_yarn)
  - [![docker](https://img.shields.io/docker/v/darthjee/production_ruby_331.svg?logo=docker&label=production_ruby_331&sort=semver)](https://hub.docker.com/r/darthjee/production_ruby_331)
  - [![docker](https://img.shields.io/docker/v/darthjee/production_ruby_3412.svg?logo=docker&label=production_ruby_3412&sort=semver)](https://hub.docker.com/r/darthjee/production_ruby_3412)
  - [![docker](https://img.shields.io/docker/v/darthjee/production_ruby_node.svg?logo=docker&label=production_ruby_node&sort=semver)](https://hub.docker.com/r/darthjee/production_ruby_node)
  - [![docker](https://img.shields.io/docker/v/darthjee/production_taa.svg?logo=docker&label=production_taa&sort=semver)](https://hub.docker.com/r/darthjee/production_taa)
  - [![docker](https://img.shields.io/docker/v/darthjee/production_taap.svg?logo=docker&label=production_taap&sort=semver)](https://hub.docker.com/r/darthjee/production_taap)
  - [![docker](https://img.shields.io/docker/v/darthjee/production_django.svg?logo=docker&label=production_django&sort=semver)](https://hub.docker.com/r/darthjee/production_django)
