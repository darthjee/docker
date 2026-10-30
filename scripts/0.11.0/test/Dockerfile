ARG DOCKER_ID_USER
ARG IMAGE
ARG VERSION

FROM $DOCKER_ID_USER/$IMAGE:$VERSION

ARG IMAGE
ARG VERSION

RUN apk add --no-cache bash

COPY $IMAGE/$VERSION/test /home/test

CMD ["/bin/bash", "/home/test/test.sh"]
