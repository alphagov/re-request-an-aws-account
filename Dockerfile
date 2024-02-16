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
COPY --from=nodebuilder /usr/local/bin /usr/local/nodebin
RUN export PATH=$PATH:usr/local/nodebin 
RUN bundle install
COPY --from=nodebuilder /opt/app/node_modules /opt/app/node_modules
RUN useradd -ms /bin/bash app
USER app
COPY --chown=app . ./
RUN RAILS_ENV=production bundle exec rake assets:precompile


# Remove node and npm since no longer needed and address CVES issues.
USER root
RUN rm -rf /opt/app/node_modules 

FROM ruby:3.2.3-slim
WORKDIR /opt/app
COPY --from=rubybuilder /usr/local/bundle /usr/local/bundle
RUN useradd -ms /bin/bash app
USER app
COPY --chown=app --from=rubybuilder /opt/app /opt/app

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "--port", "3000"]
