# Consumer Repository Guide

## 1. Add the caller workflow

Copy `docs/consumer-workflow-example.yml` into
`.github/workflows/docker-automation.yml`. The consumer owns the `cron`
expression because GitHub requires schedules to be static workflow YAML.
Cron is UTC; convert local times before committing.

> **Using a private automation repository?** If the repository providing
> `reusable-base-image-monitor.yml`/`reusable-docker-release.yml` is
> private, you must explicitly grant it cross-repository access before any
> consumer repository — including ones you own — can call it. See
> [Private Repository Access](INSTALLATION.md#private-repository-access)
> in the Installation Guide. Skipping this step produces a
> `workflow was not found` error even when the `uses:` path and ref are
> correct.

## 2. Configure variables

Start with:

```text
DOCKERFILE_PATH=Dockerfile
BUILD_CONTEXT=.
BUILD_PLATFORMS=linux/amd64,linux/arm64
DEPLOYMENT_ENVIRONMENT=production
SCAN_SEVERITY_THRESHOLD=CRITICAL,HIGH
PUBLISH_GHCR=true
GHCR_IMAGE=ghcr.io/organization-name/image-name
RELEASE_TAG_STRATEGY=BASE_TAG_INCREMENT
```

Add `TEST_COMMAND` when the image has a smoke test. Use `PATHS_IGNORE` as a
JSON array string for dynamic job-level filtering.

`BASE_TAG_INCREMENT` creates a distinct immutable release identifier for
each build, including a same-tag upstream rebuild. To retain the upstream
name such as `php8.4-apache` as a mutable image alias, also set
`PUBLISH_UPSTREAM_TAG_ALIAS=true`. For SemVer releases set
`RELEASE_TAG_STRATEGY=SEMVER_INCREMENT` and choose
`RELEASE_SEMVER_BUMP=patch`, `minor`, or `major`. See the complete release
strategy catalog in the [Configuration Guide](CONFIGURATION.md).

## 3. Configure secrets

Add only the credentials for enabled registries. Never place tokens,
passwords, or private keys in variables, workflow inputs, Dockerfiles, or
the optional YAML file.

## 4. Configure approvals

Create the environment named by `DEPLOYMENT_ENVIRONMENT` and add required
reviewers. Environment protection is a security boundary and cannot be
disabled safely through a Repository Variable.

## 5. Validate

Run the workflow manually with dry-run enabled. Confirm the Dockerfile,
candidate image, test command, scan threshold, SBOM, and calculated release
identifier. Then enable the scheduled monitor and push-based release path.
