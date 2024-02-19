# get official nodejs/npm binaries
FROM node:20.11-slim as nodebuilder
WORKDIR /opt/app
COPY package-lock.json ./
COPY package.json ./
RUN npm i

# bundle install the gems for production
FROM ruby:3.2.3 as rubybuilder
RUN apt update -y \
    && apt -y install nano \
    && cp /usr/bin/nano /usr/local/bin/
WORKDIR /opt/app
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' \
    && bundle install

# copy required files from base images, precompile assets & cleanup
FROM ruby:3.2.3-slim
WORKDIR /opt/app
COPY --from=rubybuilder /usr/local/bundle /usr/local/bundle
COPY --from=nodebuilder /usr/local/bin /usr/local/nodebin
COPY --from=nodebuilder /opt/app/node_modules /opt/app/node_modules
RUN export PATH=$PATH:usr/local/nodebin \
    && useradd -ms /bin/bash app
USER app
COPY --chown=app . ./
RUN RAILS_ENV=production bundle exec rake assets:precompile

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "--port", "3000"]
