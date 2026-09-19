ARG PULLTROUGH_REGISTRY_PREFIX=""

FROM ${PULLTROUGH_REGISTRY_PREFIX}ruby:3.3.6-bookworm

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
