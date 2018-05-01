Reliability Engineering: Request an AWS Account
===============================================

[![Build Status](https://travis-ci.org/alphagov/re-request-an-aws-account.svg?branch=master)](https://travis-ci.org/alphagov/re-request-an-aws-account)

User interface to manage AWS Accounts (e.g. for new services or environments) and users within the base AWS account.

Running locally
---------------

This is a rails app, with dependencies managed by bundler. To run the app locally clone this repo, then:

```
bundle install
bundle exec rails server
```

If you want to test the apps interaction with third party services (e.g. GitHub
and GOV.UK Notify) you'll need to set up some secrets in environment variables.
The easiest way to do this in development is using a `.env` file (see [.env.example](.env.example)):

```
cp .env.example .env
$EDITOR .env
```

Run the tests with:

```
bundle exec rails test
```

Deploying to PaaS
-----------------

There's a Travis job (see [.travis.yml](.travis.yml)) which continuously
deploys to [https://gds-request-an-aws-account.cloudapps.digital](https://gds-request-an-aws-account.cloudapps.digital).
Simply get your changes into master and make sure the build is green.

To deploy to a separate route (e.g. for testing / previewing changes) you can push to PaaS manually:

```
cf push gds-request-an-aws-account-preview
```
