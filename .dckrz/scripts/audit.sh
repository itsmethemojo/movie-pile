#!/bin/bash

set -e

bundle-audit check --update

cd .dckrz/config/docker/testing/

bundle-audit check --update
