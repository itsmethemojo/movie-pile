FROM ruby:2.7.6-slim

RUN apt-get update \
    && apt-get upgrade \
    && apt-get install -y --no-cache tzdata postgresql-client

COPY Gemfile* /app-container/

RUN cd /app-container && \
    bundle install
