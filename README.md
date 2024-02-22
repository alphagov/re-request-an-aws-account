Reliability Engineering: Request an AWS Account
===============================================

User interface to manage AWS Accounts (e.g. for new services or environments) and users within the base AWS account.

Running locally
---------------

This is a rails app, with dependencies managed by bundler. To run the app locally clone this repo, then:

```sh
bundle install
npm install
bundle exec rails server
```

If you want to test the apps interaction with third party services (e.g. GitHub
and GOV.UK Notify) you'll need to set up some secrets in environment variables.
The easiest way to do this in development is using a `.env` file (see [.env.example](.env.example)):

```sh
cp .env.example .env
$EDITOR .env
```

Run the tests with:

```sh
bundle exec rails test
```

To sign in as a development user, visit <http://localhost:3000/dev-login> (to try different email addresses, you can provide a `email` parameter). If you want to test with real Google SSO, you can [create an application in the Google Cloud Console](https://console.developers.google.com/apis/credentials).


Building Docker Image
--------------------

Note - when building the docker image on a mac arm but wanting to run the image on x86 architecture then run the `docker build` with this flag: `--platform="linux/amd64"`

Ruby App Master Key
-------------------

If running in production a master key is required to decrypt `credentials.yml.enc`. This has been created and is passed into the container/environment at runtime.


ENV vars
--------

  - `RAILS_ALLOWED_DOMAINS`: the domain of the app runtime env (eg loalhost:3000 or sub.domain.tld)
  - `RAILS_SERVE_STATIC_FILES` true|false(default)
  - `RAILS_LOG_TO_STDOUT` true : will log out errors etc since production defaults to logfile
  - `RESTRICT_LOGIN_EMAIL_ADDRESSES_TO`: `example.one@digital.cabinet-office.gov.uk example.two@digital.cabinet-office.gov.uk` - should be a space separated list of email addresses if set it will only allow those email address to log in

ENV secrets
-----------

  - `GOOGLE_CLIENT_ID`: an OAuth2 client ID
  - `GOOGLE_CLIENT_SECRET`: an OAuth2 client secret
  - `GITHUB_PERSONAL_ACCESS_TOKEN`: the PAT required to act on requied alphagov repos
  - `NOTIFY_API_KEY`: a key to use the notify api to send emails
  - `RAILS_MASTER_KEY`: the key that has been used to encode `config/credentials.yml.enc`
