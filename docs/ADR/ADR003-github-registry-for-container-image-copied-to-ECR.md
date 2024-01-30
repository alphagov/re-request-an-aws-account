# ADR003: Github registry will be used as container image registry with copies to AWS ECR for each env

Date: 2024-01-29

## Status

  * Accepted

## Context

  * A single image must be deployable to all environments
  * deployment will require an image registry accessible by app
  * docker scout should be used in build process and block push based on high/critical issues

## Decision

  * [Github image registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) as central registry
  * ECR in each AWS env with copy of image for further scanning and integration with AppRunner
  
## Considered Options

  * Github Image Registry (public): since the application is public there is no need for us to push to private registiry.  docker scout can be used in github actions
  * Docker hub: Can have registry scanning and remote image scanning active as optional extra
  * AWS ECR: need a central account for single reg or have copies of image deployed to two independent ECRs.  however ECR could have a copy of the single source of truth image pushed to it for ease of deployment (and extra scanning features).

## Consequences
  
  * Requires `docker scout pves <image-name>` and report generating within github actions for app before pushing image to registry
  * Copies of ECR will be via the infra github repo
