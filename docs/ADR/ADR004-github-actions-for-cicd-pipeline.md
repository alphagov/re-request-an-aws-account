# ADR004: Github Actions with AWS OIDC provider will be used as the (CI/CD) build, test and deploy pipeline

Date: 2024-01-29

## Status

  * Accepted 

## Context

  * A required CI/CD pipeline for a) build, test and push of docker image, b) management of infra/deployment

## Decision

  * Github Actions
    - understood well within team and GDS
    - many reusable actions
    - secure agreement between Github and AWS 
    - reusable workflows (internal to app)
    - Good support from hashicorp/terraform
    - [dedicated oidc providers under github/AWS agreement](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
	- Integrated into PR/Github/etc
    - history is maintained even if AWS accounts are removed/recreated
  * AWS/Github OIDC provider & role will be set up in each AWS acc using a separate cloudformations which is required to be run independently by SRE/Devops local machine when setting up new AWS accounts

## Considered Options

  * Github Actions: decision
  * AWS Code Pipeline: requires running pipelines within the env or having separate AWS acc for centralised approach and would require more manual config/set-up to config pipeline, outside of a pipeline.

## Consequences

  * required [OIDC provider/role](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services) set up in each AWS acc. 

