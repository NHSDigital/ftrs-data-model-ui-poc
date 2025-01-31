# Account-Wide Infrastructure

This is infrastructure that should only be deployed once per account.

> **Note**: This should be deployed using the `default` workspace.

Currently, the following resources are deployed:

1. Elastic Container Repository (ECR) for project docker images.
2. IAM role for GitHub Actions (via OIDC)
3. The base environment VPC
