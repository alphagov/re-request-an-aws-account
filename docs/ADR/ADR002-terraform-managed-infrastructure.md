# ADR002: Infrastructure will be managed using terraform

Date: 2024-01-29

## Status

  * Accepted

## Context

   * Infrastructure needs to be managed as code.

## Decision

We will use Terraform to deploy and Manage AWS AppRunner and any other necessary resources such as secrets and IAM.

## Considered Options

  * Terraform: decision
  * AWS Cloudformations: skillset in GDS and within Engineering Enablement is more aligned to TF 
  * AWS Copilot: lack of declarative properties/inter-relating resource relationships, transparency/observaility and poorly exposed errors/logging. 

## Consequences

  * We will be dependent on patching AWS provider in AWS and ensuring appropriate deployement workflow of TF.

## Other notes ##

none
