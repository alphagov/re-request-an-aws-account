---
classification: OFFICIAL-SENSITIVE
handling_group: GDS USE ONLY
last_reviewed_on: 2025-10-12
review_in: 2 years
responsible_role: Lead Developer
responsible_role_contact: https://slack.com/app_redirect?channel=gds-engineering-enablement&team=T8GT9416G
---

This repository contains:

* Infrastructure configuration as code that might be useful to an attacker - an `.env` file when using this locally
* GDS email adrresses

It's unlikely ever to be okay to make it public.

## AI Tooling

We allow Claude and GitHub Copilot Code Review, but deny these tools read access to files that contain senstive data

```
**/.env
**/.env.*
app/services/notify_service.rb
config/application.rb
test/controllers/remove_users_controller_test.rb
test/controllers/users_controller_test.rb
```

These files can contain potentially sensitive environment variables or email address. AI Coding Assistants can read and modify the code without needing access to the content of certain variables.

- Restrictions for Claude are defined in [.claude/settings.json](.claude/settings.json).

> Warning
>
> If you add new files containing personal / sensitive data, please ensure you update the .claude/settings.json blocking Claude's read access to it. A repo admin will need to update GitHub the content exclusions.
