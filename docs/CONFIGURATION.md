# Lifecycle Policy and Configuration Guide

Repository Variables are strings. Boolean values must be written as the
literal string `true` or `false`. Empty variables fall back to the optional
configuration file and then to platform defaults.

## Naming and configuration model

Variables describe repository-owned lifecycle policy; secrets provide
credentials; workflow inputs provide per-run overrides. Do not store
credentials in variables or the optional configuration file.

| Concern | Naming convention | Examples |
|---|---|---|
| Upstream monitoring | `BASE_IMAGE_*` | `BASE_IMAGE_UPDATE_POLICY`, `BASE_IMAGE_UPDATE_STRATEGY` |
| Build | `BUILD_*` | `BUILD_CONTEXT`, `BUILD_PLATFORMS` |
| Verification | `TEST_*`, `SCAN_*` | `TEST_COMMAND`, `SCAN_SEVERITY_THRESHOLD` |
| Release identity | `RELEASE_*` | `RELEASE_TAG_STRATEGY`, `RELEASE_SEMVER_BUMP` |
| Publication | `PUBLISH_*` | `PUBLISH_GHCR`, `PUBLISH_UPSTREAM_TAG_ALIAS` |
| Security | `SIGN_*` | `SIGN_IMAGES` |

For v1 compatibility, existing variable names remain authoritative. Future
prefix consolidation must be introduced as backward-compatible aliases, not
as a silent rename.

## Monitoring variables

| Variable | Type | Default | Example |
|---|---|---|---|
| `BASE_IMAGE_MONITOR_ENABLED` | boolean string | `true` | `false` |
| `BASE_IMAGE_UPDATE_STRATEGY` | enum | `patch` | `minor` |
| `BASE_IMAGE_UPDATE_POLICY` | enum | `DIGEST_AND_VERSION` | `DIGEST_ONLY` |
| `AUTO_CREATE_UPDATE_PR` | boolean string | `true` | `true` |
| `AUTO_MERGE_UPDATE_PR` | boolean string | `false` | `false` |
| `REPOSITORY_REVIEWERS` | comma-separated string | empty | `platform-team,security-team` |
| `REPOSITORY_ASSIGNEES` | comma-separated string | empty | `application-owner` |

### `BASE_IMAGE_UPDATE_STRATEGY` vs `BASE_IMAGE_UPDATE_POLICY`

These two variables answer different questions and are both applied.

- **`BASE_IMAGE_UPDATE_POLICY`** decides *which signals* are allowed to
  raise an update.
- **`BASE_IMAGE_UPDATE_STRATEGY`** decides *how far* a version bump may
  travel (`patch`, `minor`, `major`). It constrains the version signal
  only; it never suppresses a digest change.

| Policy | Digest change | Version bump | Notes |
|---|---|---|---|
| `DIGEST_AND_VERSION` | update | update | **Default.** Catches same-tag rebuilds *and* version bumps. |
| `DIGEST_ONLY` | update | ignored | Strict pinning. Never moves off the current tag. |
| `VERSION_ONLY` | ignored | update | Legacy behaviour. Misses rebuild-only security fixes. |
| `STRICT_SEMVER` | update | update, semver-parseable versions only | Rejects ambiguous or date-style versions. |
| `ALWAYS_UPDATE` | update | update | Re-pins on every run. Noisy; for testing only. |

`DIGEST_AND_VERSION` is the recommended default because publishers
routinely rebuild an image — for security patches, base image updates, or
package refreshes — **without changing the tag**. Tag comparison alone
cannot see those rebuilds; digest comparison can.

### Digest pinning

The monitor writes the base image reference back to the Dockerfile in
`image:tag@sha256:...` form. The pinned digest is both the build input and
the monitor's state: there is no separate lock file to drift, the change is
visible in the pull request diff, and the git history of the Dockerfile
becomes a tamper-evident record used for rollback detection.

For multi-architecture images the **index (manifest list) digest** is
pinned, never a per-platform digest — pinning a per-platform digest would
silently reduce the image to a single architecture.

### Registry credentials for monitoring

Reading a public upstream base image needs no credentials. Supply the
`registry-username` input and the optional `REGISTRY_PASSWORD` secret only
when the base image is private or when anonymous pull rate limits are a
problem. These must be **read-only** credentials for the upstream registry
and must never be reused as publishing credentials.

## Build and release variables

| Variable | Type | Default | Example |
|---|---|---|---|
| `DOCKERFILE_PATH` | path | `Dockerfile` | `docker/Dockerfile` |
| `BUILD_CONTEXT` | path | `.` | `./docker` |
| `BUILD_PLATFORMS` | CSV | `linux/amd64` | `linux/amd64,linux/arm64` |
| `TEST_COMMAND` | shell command | empty | `docker run --rm candidate-image:test true` |
| `DEPLOYMENT_ENVIRONMENT` | name | `production` | `staging` |
| `SCAN_SEVERITY_THRESHOLD` | CSV | `CRITICAL,HIGH` | `CRITICAL,HIGH,MEDIUM` |
| `PATHS_IGNORE` | JSON array string | empty | `["**/*.md","docs/**"]` |
| `RELEASE_BRANCHES` | CSV | `main` | `main,stable` |
| `IMAGE_NAME` | image path | empty | `organization-name/image-name` |
| `RELEASE_TAG_STRATEGY` | enum | `BASE_TAG_INCREMENT` | `SEMVER_INCREMENT` |
| `RELEASE_PREFIX` | string | empty | `wordpress` |
| `RELEASE_INCREMENT_BASENAME` | string | `release` | `release` |
| `RELEASE_SEMVER_INITIAL` | SemVer | `v1.0.0` | `v2.0.0` |
| `RELEASE_SEMVER_BUMP` | enum | `patch` | `minor` |
| `PUBLISH_UPSTREAM_TAG_ALIAS` | boolean string | `false` | `true` |
| `SIGN_IMAGES` | boolean string | `false` | `true` |

### Release identifiers and aliases

`RELEASE_TAG_STRATEGY` controls the immutable identifier used for the Git
tag, GitHub Release, and versioned OCI image tag:

| Strategy | Result |
|---|---|
| `BASE_TAG_INCREMENT` | `php8.4-apache.1`, `php8.4-apache.2` |
| `PREFIX_INCREMENT` | `wordpress.1`, `wordpress.2` |
| `RELEASE_INCREMENT` | `release.1`, `release.2` |
| `SEMVER_INCREMENT` | `v1.0.0`, `v1.0.1` |
| `DATE_INCREMENT` | `container-2026.1`, `container-2026.2` |
| `DIGEST` | `sha-4120511b044f` |
| `UPSTREAM_TAG` | `php8.4-apache` (only when not already used) |

`UPSTREAM_TAG` is safe only for an upstream tag that will never be
republished. Git release tags are immutable, while upstream OCI tags can be
mutable. When an upstream tag is rebuilt with a new digest, use one of the
unique identifier strategies above and set `PUBLISH_UPSTREAM_TAG_ALIAS=true`
to also publish `your-image:php8.4-apache` as a controlled mutable alias.

The platform never publishes `latest` implicitly. Publish the upstream tag
alias only when consumers intentionally require it; immutable release tags
and digest references are the supported deployment inputs.

Set `SIGN_IMAGES=true` to keylessly sign every published image digest with
Sigstore Cosign and GitHub OIDC. It requires `id-token: write` in the
consumer caller's permissions, which the supplied example includes.

## Registry variables

For each enabled target, set `PUBLISH_<TYPE>=true` and the corresponding
image variable. Registry host variables are required for self-hosted or
provider-specific endpoints.

| Type | Enable | Image | Optional host/region |
|---|---|---|---|
| GHCR | `PUBLISH_GHCR` | `GHCR_IMAGE` | none |
| Docker Hub | `PUBLISH_DOCKERHUB` | `DOCKERHUB_IMAGE` | none |
| ACR | `PUBLISH_ACR` | `ACR_IMAGE` | none — embed the registry hostname directly in `ACR_IMAGE`, e.g. `myregistry.azurecr.io/app` |
| ECR | `PUBLISH_ECR` | `ECR_IMAGE` | `AWS_REGION` |
| Quay | `PUBLISH_QUAY` | `QUAY_IMAGE` | none |
| Harbor | `PUBLISH_HARBOR` | `HARBOR_IMAGE` | `HARBOR_REGISTRY_HOST` |
| Artifactory | `PUBLISH_ARTIFACTORY` | `ARTIFACTORY_IMAGE` | `ARTIFACTORY_REGISTRY_HOST` |
| GitLab | `PUBLISH_GITLAB` | `GITLAB_IMAGE` | `GITLAB_REGISTRY_HOST` |
| DigitalOcean | `PUBLISH_DIGITALOCEAN` | `DIGITALOCEAN_IMAGE` | none |
| OCIR | `PUBLISH_OCIR` | `OCIR_IMAGE` | `OCIR_REGISTRY_HOST` |
| Generic OCI | `PUBLISH_PRIVATE` | `PRIVATE_IMAGE` | `PRIVATE_REGISTRY_HOST` |

The current reusable workflow accepts the host-specific variables listed in
its inputs. ACR, Docker Hub, Quay, DigitalOcean, and GHCR have no separate
host variable — always embed the full registry hostname in the `<TYPE>_IMAGE`
value itself.

## Optional configuration file

Use `.github/docker-automation.yml` only when you need nested, reviewable
configuration or multiple instances of the same registry type. See
[`templates/docker-automation.yml`](../templates/docker-automation.yml).

## Environment guidance

Use a GitHub Environment for every production publication target. Store
production registry credentials as Environment secrets, require reviewers on
the environment, and restrict access to protected release branches. For cloud
registries, prefer OIDC to long-lived access keys.
