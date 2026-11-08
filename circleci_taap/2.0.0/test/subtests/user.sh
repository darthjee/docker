#!/bin/bash

USER_NAME=$(whoami)

if [ "$USER_NAME" != "circleci" ]; then
  echo "expected to run as circleci, but running as $USER_NAME"
  exit 1
fi
