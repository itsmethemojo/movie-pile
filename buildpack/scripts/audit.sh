#!/bin/bash

set -e

bundle-audit check --update

cd buildpack/config/docker/testing/

bundle-audit check --update
