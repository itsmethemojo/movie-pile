FROM ruby:2.7

RUN mkdir /app-container

COPY Gemfile* /app-container/

RUN cd /app-container && \
    bundle install

RUN cat /app-container/Gemfile.lock
