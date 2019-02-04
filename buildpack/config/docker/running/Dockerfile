FROM ruby

RUN mkdir /app-container

COPY Gemfile /app-container/

RUN cd /app-container && \
    bundle install
