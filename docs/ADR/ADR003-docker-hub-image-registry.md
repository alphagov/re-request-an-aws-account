# ADR003: Docker hub will be used as container image registry

Date: 2024-01-29

## Status

  * Proposed (note requires investigation into apprunner integration with docker hub)

## Context

  * A single image must be deployable to all environments
  * deployment will require an image registry

## Decision

  * Docker hub: GDS pay for business licenses that give access to advanced features such as security scanning (source GOV.UK team) which is potentially more advanced than github or AWS image scanning - this offers a single, isolated, image registry to deploy the same image to each env.

## Considered Options

  * Docker hub: decision
  * Github Registry: less capable security image scanning 
  * AWS ECR: need a central account for single reg or have copies of image deployed to two independent ECRs.

## Consequences

  * We need to understand AppRunner's deployment mechanism, it will need access to dockerhub private reg.
  * It may be necessary/easier to deploy the image into apprunner from ECR (even if it means multiple copies of image)

## Other Notes ##

  * Requires a bit of investigation/spike
