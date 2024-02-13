#TODO pin all versions to sha digest
#TODO add .dockerignore
#TODO add non root user
FROM node:20.11-slim as nodebuilder
WORKDIR /opt/app
COPY package-lock.json ./
COPY package.json ./
RUN npm install

FROM ruby:3.2 as rubybuilder
RUN apt update -y && apt -y install rsync 
WORKDIR /opt/app
COPY Gemfile Gemfile.lock ./
RUN bundle install
COPY --from=nodebuilder /usr/local/bin /usr/local/nodebin
RUN rsync -a /usr/local/nodebin /usr/local/bin

FROM ruby:3.2-slim
WORKDIR /opt/app
COPY --from=rubybuilder /usr/local/bundle /usr/local/bundle
COPY --from=rubybuilder /usr/local/bin /usr/local/bin
COPY --from=nodebuilder /opt/app/node_modules /opt/app/node_modules
COPY --from=nodebuilder /usr/local/lib/node_modules /usr/local/bin/node_modules

RUN useradd -ms /bin/bash app
USER app
COPY --chown=app . ./
RUN RAILS_ENV=production SECRET_KEY_BASE=assets bundle exec rake assets:precompile

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "--port", "3000"]

