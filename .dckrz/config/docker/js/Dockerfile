FROM node:14.14-stretch

RUN mkdir /app

COPY package.json package-lock.json /app/

RUN cd /app && npm install

WORKDIR /app
