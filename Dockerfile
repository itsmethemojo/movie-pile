FROM ruby:2.7

RUN mkdir /app

COPY Gemfile* /app/

RUN cd /app && \
    bundle install

COPY app/ config/ public/ src/ views/ /app-container/

WORKDIR /app
