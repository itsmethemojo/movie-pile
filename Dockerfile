FROM ruby:2.7

RUN mkdir /app-container

COPY Gemfile* /app-container/

RUN cd /app-container && \
    bundle install

COPY app/ config/ public/ src/ views/ /app-container/


