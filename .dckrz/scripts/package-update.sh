#!/bin/bash

#gem update bundler
#bundle update
gem install bigdecimal -v 3.0.2
cd .dckrz/config/docker/testing && bundle install && bundle update
