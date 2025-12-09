# get official nodejs/npm binaries
ARG RUBY_VERSION
ARG NODE_VERSION
FROM node:${NODE_VERSION}-alpine AS nodebuilder

WORKDIR /opt/app
COPY package-lock.json package.json ./
RUN npm ci


# bundle install the gems for production
FROM ruby:${RUBY_VERSION}-alpine AS rubybuilder

RUN apk update && apk add --no-cache \
    build-base \
    postgresql-dev \
    tzdata \
    linux-headers \
    libxml2-dev \
    libxslt-dev \
    nodejs \
    gcompat \
    yaml-dev

WORKDIR /opt/app
COPY Gemfile Gemfile.lock ./

RUN bundle config set without development && \
    bundle config set without test && \
    bundle config --delete without && \
    bundle config --delete with && \
    bundle install


FROM ruby:${RUBY_VERSION}-alpine
WORKDIR /opt/app

COPY --from=rubybuilder /usr/local/bundle /usr/local/bundle
COPY --from=nodebuilder /usr/local/bin /usr/local/nodebin
COPY --from=nodebuilder /opt/app/node_modules /opt/app/node_modules

RUN apk add --no-cache \
    gcompat \
    libstdc++

ENV PATH="${PATH}:/usr/local/nodebin"

RUN adduser -D -s /bin/sh app
USER app

COPY --chown=app . ./

RUN RAILS_ENV=production bundle exec rake assets:precompile

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "--port", "3000"]
