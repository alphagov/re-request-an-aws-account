#TODO pin all versions to sha digest
#TODO add .dockerignore
FROM node:20.11-slim as nodebuilder
WORKDIR /opt/app
COPY package-lock.json ./
COPY package.json ./
RUN npm install


FROM ruby:3.2.3 as rubybuilder
RUN apt update -y && apt -y install nano
RUN cp /usr/bin/nano /usr/local/bin/
WORKDIR /opt/app
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test'
RUN bundle install

FROM ruby:3.2.3-slim
WORKDIR /opt/app
COPY --from=rubybuilder /usr/local/bundle /usr/local/bundle
COPY --from=nodebuilder /usr/local/bin /usr/local/nodebin
COPY --from=nodebuilder /opt/app/node_modules /opt/app/node_modules
RUN export PATH=$PATH:usr/local/nodebin
RUN useradd -ms /bin/bash app
USER app
COPY --chown=app . ./
RUN RAILS_ENV=production bundle exec rake assets:precompile
USER root
RUN rm -rf /usr/local/nodebin && rm -rf /opt/app/node_modules
USER app

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "--port", "3000"]
