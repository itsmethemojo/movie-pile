FROM ruby:2.7.6-slim

RUN apt-get update \
    && apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends tzdata libffi-dev gcc make libpq-dev curl

COPY Gemfile Gemfile.lock /app/

RUN cd /app && \
    bundle install

COPY app /app/app

COPY config /app/config

COPY public /app/public

COPY src /app/src

COPY views /app/views

COPY entrypoint.sh /

WORKDIR /app

ENV APP_ENVIRONMENT=production

CMD ["/entrypoint.sh"]
