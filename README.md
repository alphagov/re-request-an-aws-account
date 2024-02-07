# Reliability Engineering: Request an AWS Account

User interface to manage AWS Accounts (e.g. for new services or environments)
and users within the base AWS account.

## Running locally

This is a rails app, with dependencies managed by bundler. To run the app
locally clone this repo, then:

```shell
bundle install
npm install
bundle exec rails server
```

If you want to test the apps interaction with third party services (e.g. GitHub
and GOV.UK Notify) you'll need to set up some secrets in environment variables.
The easiest way to do this in development is using a `.env` file (see
[.env.example](.env.example)):

```shell
cp .env.example .env
$EDITOR .env
```

Run the tests with:

```shell
bundle exec rails test
```

To sign in as a development user, visit <http://localhost:3000/dev-login> (to
try different email addresses, you can provide a `email` parameter). If you want
to test with real Google SSO, you can
[create an application in the Google Cloud Console](https://console.developers.google.com/apis/credentials).

## Building the Docker image

In order to move this app away from GOV.UK PaaS, we have containerised the
application in order to be able to run locally and also deploy to AWS App
Runner. The app can be accessed on port 3000.

To build and run the Docker image:

```shell
docker build -t request-an-aws-account .
docker run -p 3000:3000 -t request-an-aws-account
```

## Deploying through GitHub Actions

We use a GitHub Action to automate the building and deploying of our Docker
image to GHCR. This workflow runs every time a PR is raised to the branch called
'main'. It uses the `docker/login-action`, `docker/metadata-action`, and
`docker/build-push-action`.

You can [view the workflow at ghcr.yml](https://github.com/alphagov/re-request-an-aws-account/blob/dockerise-basic/.github/workflows/ghcr.yml).


The workflow utilizes the following GitHub Actions:

- [`docker/login-action`](https://github.com/docker/login-action) for logging in
to Docker. 
- [`docker/metadata-action`](https://github.com/docker/metadata-action)
for generating Docker image metadata.
- [`docker/build-push-action`](https://github.com/docker/build-push-action) for
building and pushing the Docker image.

This process ensures our Docker images are automatically built and pushed to the
GitHub Container Registry (GHCR), streamlining our deployment process.

## Deploying to PaaS

This is continuously deployed from master
[by Github Actions](https://github.com/alphagov/re-request-an-aws-account/blob/master/.github/workflows/bundle_and_release.yml)

To deploy to a separate route (e.g. for testing / previewing changes) you can
push to PaaS manually:

```shell
cf push gds-request-an-aws-account-preview
```
