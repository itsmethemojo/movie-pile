FROM ruby:2.7

RUN mkdir /app

COPY Gemfile* /app/

RUN cd /app && \
    bundle install

COPY . /app/

WORKDIR /app
