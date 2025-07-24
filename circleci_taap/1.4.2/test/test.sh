#!/bin/bash

for TEST in /home/test/subtests/*.sh; do
  /bin/bash $TEST || exit 0
done

