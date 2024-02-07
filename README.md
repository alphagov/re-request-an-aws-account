# Reliability Engineering: Request an AWS Account

User interface to manage AWS Accounts (e.g. for new services or environments) and users within the base AWS account.

## Running locally

This is a rails app, with dependencies managed by bundler. To run the app locally clone this repo, then:

```shell
bundle install
npm install
bundle exec rails server
```

If you want to test the apps interaction with third party services (e.g. GitHub
and GOV.UK Notify) you'll need to set up some secrets in environment variables.
The easiest way to do this in development is using a `.env` file (see [.env.example](.env.example)):

```shell
cp .env.example .env
$EDITOR .env
```

Run the tests with:

```shell
bundle exec rails test
```

To sign in as a development user, visit <http://localhost:3000/dev-login> (to try different email addresses, you can provide a `email` parameter). If you want to test with real Google SSO, you can [create an application in the Google Cloud Console](https://console.developers.google.com/apis/credentials).

## Deploying to PaaS

This is continuously deployed from master [by Github Actions](https://github.com/alphagov/re-request-an-aws-account/blob/master/.github/workflows/bundle_and_release.yml)

To deploy to a separate route (e.g. for testing / previewing changes) you can push to PaaS manually:

```shell
cf push gds-request-an-aws-account-preview
```
