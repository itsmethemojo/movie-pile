#!/bin/bash

docker run -v $(pwd):/app ruby bash -c "cd /app; bundle update"
docker run -v $(pwd)
