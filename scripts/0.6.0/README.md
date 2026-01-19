darthjee/scripts

Scripts
=======

This repository contains several Docker images, each organized in its own folder and version. This documentation refers to the scripts image.

## About the image

The scripts image is a collection of auxiliary scripts, organized to facilitate both the building of other Docker images and development inside containers.

### Scripts structure

- **builder/**  
  Scripts mainly used during the build process of other Docker images. Examples include dependency installers like `yarn_installer` and other utilities needed to prepare build environments.

- **sbin/**  
  Scripts added to the final images for use during development. Examples:
  - `build_gem`: automates the process of building Ruby gems.
  - `check_specs`: runs automated tests.
  - Other utility scripts for common development tasks.

## How to use

This image is not intended for standalone use, but rather as a base or complement for other Docker images, providing ready-to-use tools and utilities.

You can use the scripts directly in your Dockerfiles or during development, as needed by your project.

## Usage example

```dockerfile
FROM darthjee/scripts:latest as scripts
FROM <base_image> as base

# Base building

##### BUILD STEP #######

FROM base as builder
# build image

COPY --from=scripts /home/scripts/builder/bundle_builder.sh /usr/local/sbin/bundle_builder.sh
RUN /bin/bash bundle_builder.sh

##### FINAL STEP #######
FROM base as builder

COPY --chown=app:app --from=builder /home/app/bundle/ /usr/local/bundle/

COPY --from=scripts /home/scripts/sbin/check_spec /usr/local/sbin/


#Final building
```

## License

See the LICENSE file for more information.
