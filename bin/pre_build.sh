#!/bin/bash

function pre_build() {
  IMAGE=$2
  VERSION=$(grep "^$IMAGE=" version | sed -e "s/$IMAGE=//g")
  BASE=$(grep "^FROM" $IMAGE/$VERSION/Dockerfile | head -n 1 | sed -e "s/FROM *//g" -e "s/ .*//g")

  docker run -it --rm --volume=$(pwd)/$IMAGE/$VERSION/home:/home/app/app $BASE /bin/bash
}
