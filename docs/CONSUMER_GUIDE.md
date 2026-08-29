# Adopting Repository Guide

## Choose an adoption path

| Goal | Template | Required configuration |
|---|---|---|
| Resolve one public image digest | [`examples/digest-monitor.yml`](../examples/digest-monitor.yml) | None |
| Monitor an upstream image and open reviewable PRs | [`templates/minimal-monitor.yml`](../templates/minimal-monitor.yml) | Dockerfile path; optional policy/reviewers |
| Release a signed image to GHCR | [`templates/secure-release.yml`](../templates/secure-release.yml) | Build, release, and GHCR variables |
| Govern multi-platform, approval-gated releases | [`templates/enterprise-release.yml`](../templates/enterprise-release.yml) | Environment, policy, registry, and OIDC configuration |

Copy the selected template to `.github/workflows/image-lifecycle.yml`. The
adopting repository owns the `cron` expression because GitHub requires
schedules to be static workflow YAML. Cron is UTC; convert local times before
committing.

> **Using a private automation repository?** If the repository providing
> `reusable-base-image-monitor.yml`/`reusable-docker-release.yml` is
> private, you must explicitly grant it cross-repository access before any
> consumer repository — including ones you own — can call it. See
> [Private Repository Access](INSTALLATION.md#private-repository-access)
> in the Installation Guide. Skipping this step produces a
> `workflow was not found` error even when the `uses:` path and ref are
> correct.

## Five-minute monitor setup

For the minimal monitor, start with:

```text
DOCKERFILE_PATH=Dockerfile
BASE_IMAGE_UPDATE_POLICY=DIGEST_AND_VERSION
BASE_IMAGE_UPDATE_STRATEGY=patch
```

Run a manual dry run. The workflow resolves the current upstream digest and
reports whether it would open a pull request. Enable the schedule after
reviewing the result.

## Secure release setup

Add these variables when adopting the secure release template:

```text
BUILD_CONTEXT=.
BUILD_PLATFORMS=linux/amd64,linux/arm64
DEPLOYMENT_ENVIRONMENT=production
SCAN_SEVERITY_THRESHOLD=CRITICAL,HIGH
PUBLISH_GHCR=true
GHCR_IMAGE=ghcr.io/organization-name/image-name
RELEASE_TAG_STRATEGY=SEMVER_INCREMENT
SIGN_IMAGES=true
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

## Configure secrets

Add only the credentials for enabled registries. Never place tokens,
passwords, or private keys in variables, workflow inputs, Dockerfiles, or
the optional YAML file.

## Configure approvals

Create the environment named by `DEPLOYMENT_ENVIRONMENT` and add required
reviewers. Environment protection is a security boundary and cannot be
disabled safely through a Repository Variable.

## Validate and enable

Run the workflow manually with dry-run enabled. Confirm the Dockerfile,
candidate image, test command, scan threshold, SBOM, and calculated release
identifier. Then enable the scheduled monitor and push-based release path.

See [Configuration](CONFIGURATION.md) for the complete variable catalog and
[Terminology](TERMINOLOGY.md) for the platform's lifecycle vocabulary.
