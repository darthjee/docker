#!/bin/bash
set -e
ruby --version | grep -q '^ruby 3\.4\.' || { echo "expected Ruby 3.4, got $(ruby --version)"; exit 1; }
gem --version && bundle --version
