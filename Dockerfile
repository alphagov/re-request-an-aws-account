ARG ruby_version=3.2
ARG base_image=ghcr.io/alphagov/govuk-ruby-base:$ruby_version
ARG builder_image=ghcr.io/alphagov/govuk-ruby-builder:$ruby_version

FROM $builder_image AS builder

WORKDIR $APP_HOME
# $APP_HOME=/app

# RUN adduser --disabled-password ruby
# RUN mkdir /node_modules && chown ruby:ruby -R /node_modules $APP_HOME
# RUN mkdir -p /usr/local/bundle && chown :ruby -R /usr/local/bundle && chmod g+w /usr/local/bundle

#USER ruby

COPY  Gemfile* .ruby-version ./
#COPY --chown=ruby:ruby Gemfile* .ruby-version ./
RUN bundle install --verbose

COPY  package.json yarn.lock ./
# COPY --chown=ruby:ruby package.json yarn.lock ./
RUN npm ci --ignore-scripts

## From https://github.com/alphagov/forms-runner/blob/main/Dockerfile
# ENV RAILS_ENV="${RAILS_ENV:-production}" \
#     NODE_ENV="${NODE_ENV:-production}" \
#     PATH="${PATH}:/home/ruby/.local/bin:/node_modules/.bin" \
#     USER="ruby" \
#     REDIS_URL="${REDIS_URL:-redis://notset/}"

# COPY --chown=ruby:ruby . .
COPY  . .

## From https://github.com/alphagov/forms-runner/blob/main/Dockerfile
# you can't run rails commands like assets:precompile without a secret key set
# even though the command doesn't use the value itself
RUN SECRET_KEY_BASE=dummyvalue rails assets:precompile && rm -fr log

# Remove devDependencies once assets have been built
RUN npm ci --ignore-scripts --only=production

CMD ["bash"]



FROM $base_image

## From https://github.com/alphagov/forms-runner/blob/main/Dockerfile
# ENV RAILS_ENV="${RAILS_ENV:-production}" \
#     PATH="${PATH}:/home/ruby/.local/bin" \
#     USER="ruby"

ENV GOVUK_APP_NAME=re-request-an-aws-account
WORKDIR $APP_HOME

RUN adduser --disabled-password ruby
RUN chown ruby:ruby -R $APP_HOME

COPY --chown=ruby:ruby bin/ ./bin
RUN chmod 0755 bin/*

COPY --chown=ruby:ruby --from=builder /usr/local/bundle /usr/local/bundle
COPY --chown=ruby:ruby --from=builder $APP_HOME $APP_HOME

EXPOSE 3000

CMD ["/bin/sh", "-o", "xtrace", "-c", "rails s -b 0.0.0.0"]