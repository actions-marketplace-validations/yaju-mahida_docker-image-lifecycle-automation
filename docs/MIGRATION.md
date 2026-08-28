# Migration Guide

## From repository-specific GitHub Actions

1. Inventory existing triggers, Dockerfile paths, build arguments, tests,
   scanners, registries, and release tags.
2. Copy the consumer workflow example.
3. Move non-sensitive settings to Repository Variables.
4. Move credentials to Secrets and approvals to a GitHub Environment.
5. Compare a dry-run build and scan with the existing workflow.
6. Disable and remove the old workflow only after the new path succeeds.
7. Record the previous immutable platform workflow reference for rollback.

## From repository-specific Docker workflows

Map inline steps to the standard lifecycle: monitor, version, build, test,
scan, release, and publish. Use the optional configuration file if the old
workflow contains multiple registry targets or nested settings that cannot
be represented by scalar variables.

## From Jenkins

Replace Jenkins credentials with GitHub Secrets or OIDC. Replace scheduled
jobs with a consumer-owned GitHub Actions cron. Map approval stages to GitHub
Environments and required reviewers. Store build context and platform
settings as Repository Variables. Run a parallel validation period before
cutover.

## From Azure DevOps

Replace service connections with GitHub OIDC where supported or scoped
Secrets where necessary. Map environments and approvals to GitHub
Environments. Replace pipeline schedules with static consumer workflow
cron. Confirm registry permissions and artifact retention policies.

## Rollback

Revert the consumer caller's reusable-workflow reference to the previous
immutable platform version, then rerun it in dry-run mode. Do not retain or
re-enable duplicate release workflows: two release paths on the same branch
can publish conflicting mutable aliases and create competing release tags.
