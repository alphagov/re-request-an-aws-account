Reliability Engineering: Request an AWS Account
===============================================

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

To sign in as a development user, visit <http://localhost:3000/dev-login>.

Deploying to PaaS
-----------------

This is continuously deployed from master by the [multi-tenant Concourse](https://cd.gds-reliabilty.engineering) via the [internal-apps pipeline in the tech-ops repo](https://github.com/alphagov/tech-ops/blob/master/reliability-engineering/pipelines/internal-apps.yml).


To deploy to a separate route (e.g. for testing / previewing changes) you can push to PaaS manually:

```
cf push gds-request-an-aws-account-preview
```
