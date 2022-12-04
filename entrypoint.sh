#!/bin/bash
ruby app/server.rb -p 3000 -o 0.0.0.0 -e ${APP_ENVIRONMENT}
