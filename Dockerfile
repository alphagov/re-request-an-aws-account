FROM ruby:3.1-slim
ENV INSTALL_PATH /opt/app
WORKDIR /opt/app

ARG REFRESHED_AT
ENV REFRESHED_AT $REFRESHED_AT
ENV RAILS_ENV production
ARG NODE_MAJOR=20

COPY . .



RUN buildDeps='gcc g++ make nodejs build-essential ruby-dev' \
  && apt-get update -qq \
  && apt-get install -qq --no-install-recommends curl gpg \
	&& printf 'Package: nodejs\nPin: origin deb.nodesource.com\nPin-Priority: 1001' > /etc/apt/preferences.d/nodesource \
  && mkdir -p /etc/apt/keyrings \
  && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
  && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
  && apt-get update -qq \
  && apt-get install -qq --no-install-recommends $buildDeps \
  && apt-get upgrade -qq \
  && bundle install --local \
  && npm install \
  && bundle exec rake assets:precompile \
  && SUDO_FORCE_REMOVE=yes \
  && apt-get purge -y --auto-remove $buildDeps curl gpg libc6-dev zlib1g-dev libcrypt-dev \
  && apt-get clean

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "--port", "3000"]



