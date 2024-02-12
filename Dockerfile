#TODO pin all versions to sha digest
#TODO add .dockerignore
#TODO add non root user
FROM node:20.11-slim as nodebuilder

WORKDIR /opt/app
COPY package-lock.json ./
COPY package.json ./
RUN npm install

FROM ruby:3.2 as rubybuilder
 
# Default directory
RUN apt update -y && apt -y install rsync 
WORKDIR /opt/app
COPY . .
RUN bundle install
COPY --from=nodebuilder /usr/local/bin /usr/local/nodebin
RUN rsync -a /usr/local/nodebin /usr/local/bin
COPY --from=nodebuilder /opt/app/node_modules /opt/app/node_modules
COPY --from=nodebuilder /usr/local/lib/node_modules /usr/local/bin/node_modules
RUN bundle exec rake assets:precompile

FROM ruby:3.2-slim
WORKDIR /opt/app
COPY . .
COPY --from=rubybuilder /usr/local/bundle /usr/local/bundle
COPY --from=rubybuilder /usr/local/bin /usr/local/bin/
COPY --from=rubybuilder /opt/app/public /opt/app/public
EXPOSE 3000

CMD ["bundle", "exec", "rails", "server"]



