# ADR001: Target Platform is AWS AppRunner #

Date: 2024-01-29

## Status ##

Accepted

## Context ##

GDS PaaS is legacy platform for internal GDS applications.  It is
being decommisioned and business critical applications need
replatforming.  The Request and AWS Account Tool provides a way of
requesting either an AWS account to be created and/or users to be
added to AWS IAM (gds-users).

It is a ruby on rails app and consists of a simple web server
rendering form elements (such as email/user, or account name and
reason) and some controllers to receive submitted data.  Submitted
data is formatted into terraform and PR are raised via github PAT in
the aws-billing-account github repo where they are actioned by various
SREs across GDS on rota.

Uses of application are infrequent, maybe just a couple of
times a week( or day at peak use times). The response times for the
request are typically sub-second and one account being requested might
result in 4-5 request/responses to/fronm the server. However, the tool
is business critical and it needs to follow an straightforward UI/UX.

## Decision ##

 - We can run the application in a container with as close as possible
   environment which it currently has (ruby, gems, npm, nodejs, git).
 - [AWS AppRunner](https://aws.amazon.com/apprunner/): is a serverless container environment, has a very
   small constant cost for memory to keep it warm and then slightly
   higher cost with each request for the response runtime.  No need to
   pay for alb etc, all networking is provided.  Integrates nicely
   with AWS parameter store/secrets which is our other key dependency.

## Considered Options ##

  - AWS AppRunner: Decision.
  - AWS ECS: The container environment runs all the time although it can
    be stopped and started on a timed basis.  There would be need to
    pay for load balancers and constant runtime of application (which
    can be $100s a month)
  - AWS Lambda + S3: the app suits a static site in s3 backed with a lambda API
    however there is no scope to redevelop the solution and App runner
    should provide this
  - Github/Issue or slack tempalte: Requests could be raised in Github
    through a templated issue which could trigged a github action to
    do the work the ruby app does, however, not everyone has access to
    the Alpha gov repo and we don't want to make this public, nor do
    we want to redevelop the solution.
  
  
## notes ##

Other ADRS required:

  - Deployment pipeline
  - Google SSO/OAuth - user auth
  - secrets management and deployment
  - monitoring/alerts

