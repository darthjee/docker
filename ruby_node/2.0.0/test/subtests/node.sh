#!/bin/bash
set -e
node --version | grep -q '^v24\.' || { echo "expected Node 24, got $(node --version)"; exit 1; }
node /home/test/test.js
