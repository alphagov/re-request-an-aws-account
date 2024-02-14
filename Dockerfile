#TODO pin all versions to sha digest
#TODO add .dockerignore
FROM node@sha256:ecc9a2581f8588014a49a523a9ed146d27963f6d988d11bd16bbdcb3598f5f98 as nodebuilder
WORKDIR /opt/app
COPY package-lock.json ./
COPY package.json ./
RUN npm install

FROM ruby@sha256:ddc5729409d1d3222e74a5edb62d142ebd5fa47e9a98fc2905d66056eec6ae3b as rubybuilder
RUN apt update -y && apt -y install rsync nano
RUN cp /usr/bin/nano /usr/local/bin/

WORKDIR /opt/app
COPY Gemfile Gemfile.lock ./
COPY --from=nodebuilder /usr/local/bin /usr/local/nodebin
RUN rsync -a /usr/local/nodebin /usr/local/bin
RUN bundle install

FROM ruby@sha256:04da59d84a16b6db4a6663a6940a5142d79a50d8727acd00f10c3701cdeb46b0
WORKDIR /opt/app
COPY --from=rubybuilder /usr/local/bundle /usr/local/bundle
COPY --from=rubybuilder /usr/local/bin /usr/local/bin
COPY --from=nodebuilder /opt/app/node_modules /opt/app/node_modules
COPY --from=nodebuilder /usr/local/lib/node_modules /usr/local/bin/node_modules

RUN useradd -ms /bin/bash app
USER app
COPY --chown=app . ./
RUN RAILS_ENV=production bundle exec rake assets:precompile

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "--port", "3000"]
