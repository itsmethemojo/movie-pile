FROM ruby:2.7.6-slim

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y libffi-dev gcc make libpq-dev curl

COPY Gemfile* /app/

RUN cd /app && \
    bundle install

COPY app /app/app

COPY config /app/config

COPY public /app/public

COPY src /app/src

COPY views /app/views

WORKDIR /app
