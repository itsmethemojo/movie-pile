#!/bin/bash

task server
docker run --rm -v $(pwd):/app -w /app -p3000:3000 buildpack-task-server ruby app/server.rb -p 3000 -o 0.0.0.0 -e development
