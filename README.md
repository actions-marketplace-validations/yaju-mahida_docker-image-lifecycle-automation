# Docker Image Lifecycle

[![GitHub Marketplace](https://img.shields.io/badge/GitHub%20Marketplace-Docker%20Image%20Lifecycle-blue?logo=github)](https://github.com/marketplace)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](LICENSE)
[![OCI](https://img.shields.io/badge/OCI-compatible-2496ED?logo=docker&logoColor=white)](https://opencontainers.org/)

Automate the secure container image lifecycle with GitHub Actions: detect
base-image changes by digest, create reviewable updates, build and test
multi-platform images, scan vulnerabilities, generate SBOMs, sign published
digests, create releases, and publish to OCI registries.

## Marketplace Action and lifecycle workflows

The root Marketplace Action resolves any OCI image tag to its immutable
manifest digest. Use it for focused digest monitoring:

```yaml
- id: upstream
  uses: yaju-mahida/docker-image-lifecycle@v1
  with:
    registry: docker.io
    repository: library/nginx
    tag: stable

- run: echo "${{ steps.upstream.outputs.digest }}"
```

For the complete lifecycle, copy
[`templates/consumer-workflow.yml`](templates/consumer-workflow.yml) into a
consumer repository. It calls the reusable monitoring and release workflows.

```text
Scheduled monitor
        ↓
OCI digest and version detection
        ↓
Reviewable Dockerfile update PR
        ↓
Approval and merge
        ↓
Build → test → scan → SBOM → publish → sign → GitHub Release
```

## Core capabilities

- OCI-native, digest-first base image monitoring for public and private
  Docker Hub, GHCR, ACR, ECR, Quay, Harbor, Artifactory, GitLab, OCIR, and
  generic OCI registries
- Dockerfile `image:tag@sha256:...` pinning and same-tag rebuild detection
- Configurable update policies and patch/minor/major version constraints
- Multi-platform Docker Buildx image builds and smoke testing
- Hadolint, Trivy, SPDX SBOMs, BuildKit provenance, and optional keyless
  Cosign signing of published image digests
- Consumer-controlled release identifiers and opt-in mutable upstream aliases
- Publication to GHCR, Docker Hub, ACR, ECR, Quay, Harbor, Artifactory,
  GitLab Registry, DigitalOcean, OCIR, and generic OCI registries
- GitHub Environments, least-privilege permissions, OIDC, and reviewed PRs

## Quick start

1. Copy [`templates/consumer-workflow.yml`](templates/consumer-workflow.yml)
   to `.github/workflows/docker-image-lifecycle.yml` in the image repository.
2. Replace `your-org/docker-image-lifecycle@v1` with the platform reference.
3. Configure Repository Variables such as `DOCKERFILE_PATH`,
   `BUILD_PLATFORMS`, `RELEASE_TAG_STRATEGY`, and the selected `PUBLISH_*`
   registry settings.
4. Add only the matching registry secrets and create the configured GitHub
   Environment for approval-gated publication.
5. Run the caller manually in dry-run mode before enabling scheduled and
   production releases.

## Supported integration models

| Need | Use |
|---|---|
| Resolve an OCI tag to a digest | Root Marketplace Action (`yaju-mahida/docker-image-lifecycle@v1`) |
| Monitor a Dockerfile and create update PRs | `reusable-base-image-monitor.yml` |
| Build, secure, release, and publish an image | `reusable-docker-release.yml` |
| Deploy a standard consumer configuration | `templates/consumer-workflow.yml` |
| Configure multiple/custom registries | `templates/docker-automation.yml` |

## Documentation

| Topic | Guide |
|---|---|
| Install and private-repository access | [Installation](docs/INSTALLATION.md) |
| Consumer onboarding | [Consumer Guide](docs/CONSUMER_GUIDE.md) |
| Variables, policies, and release strategies | [Configuration](docs/CONFIGURATION.md) |
| Digest-first monitoring | [Monitoring](docs/MONITORING.md) |
| Registry publishing | [Registries](docs/REGISTRIES.md) |
| Architecture | [Architecture](docs/ARCHITECTURE.md) |
| Public examples | [Examples](docs/EXAMPLES.md) |
| Marketplace release information | [Marketplace](docs/MARKETPLACE.md) |
| Security policy | [Security](SECURITY.md) |

## Security

Use immutable image digests or release tags for deployment. Mutable aliases
such as `latest`, `stable`, and upstream tags are opt-in convenience labels,
not secure deployment inputs. Set `SIGN_IMAGES=true` to keylessly sign every
published image digest using Cosign and GitHub OIDC.

See [SECURITY.md](SECURITY.md) for reporting and responsibility guidance.

## Contributing and license

Contributions are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md), the
[Code of Conduct](CODE_OF_CONDUCT.md), and [Governance](GOVERNANCE.md).

Licensed under the [Apache License 2.0](LICENSE).