# ADR003: Docker hub will be used as container image registry

Date: 2024-01-29

## Status

  * Accepted

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

  * [AWS acc will need to be able to log into Docker hub](https://aws.amazon.com/blogs/containers/authenticating-with-docker-hub-for-aws-container-services/) 
  * [configure appRunner to use private docker hub as mentioned in this blog post](https://www.pulumi.com/ai/answers/6U4EwDmaAv9j1TYxyEZqfU/deploying-docker-images-on-aws-with-typescript)
