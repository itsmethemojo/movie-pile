#!/bin/bash

cd .dckrz/config/docker/js
#rm package-lock.json
#npm install
npm audit
cat package.json
npm search jscs | head -2 | tail -1
npm search jshint | head -2 | tail -1
npm search uglify-js | head -2 | tail -1
