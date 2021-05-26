#!/bin/bash

/app/node_modules/jscs/bin/jscs views/javascript --fix && /app/node_modules/jshint/bin/jshint views/javascript
