# Docker Image Lifecycle Automation

[![GitHub Marketplace](https://img.shields.io/badge/GitHub%20Marketplace-Docker%20Image%20Lifecycle%20Automation-blue?logo=github)](https://github.com/marketplace)
[![License: Apache-2.0](https://img.shields.io/badge/License-Apache--2.0-blue.svg)](LICENSE)
[![OCI](https://img.shields.io/badge/OCI-compatible-2496ED?logo=docker&logoColor=white)](https://opencontainers.org/)

Detect upstream container-image drift, create reviewed Dockerfile updates,
and release trusted OCI images with GitHub Actions. Docker Image Lifecycle
Automation uses immutable manifest digests to detect tag moves and same-tag
rebuilds, then provides a governed path through build, test, scan, SBOM,
provenance, signing, release, and multi-registry distribution.

> **Most tools detect a changed tag. This platform detects a changed image.**

## Start at the right level

Choose the smallest adoption path that solves your problem:

| Goal | Start here | Time to first result |
|---|---|---:|
| Resolve and pin an OCI image digest | [Digest monitor example](examples/digest-monitor.yml) | 1 minute |
| Detect base-image drift and open a reviewable PR | [Minimal monitor template](templates/minimal-monitor.yml) | 5 minutes |
| Build, verify, sign, release, and publish images | [Secure lifecycle template](templates/secure-release.yml) | 10 minutes |
| Apply environment gates and organization policy | [Enterprise lifecycle template](templates/enterprise-release.yml) | 15 minutes |

The root Marketplace Action resolves any OCI image tag to its immutable
manifest digest:

```yaml
- id: upstream
  uses: yaju-mahida/docker-image-lifecycle@v1
  with:
    registry: docker.io
    repository: library/nginx
    tag: stable

- run: echo "${{ steps.upstream.outputs.digest }}"
```

For the complete lifecycle, copy a template into the adopting repository.
The templates call the reusable monitoring and release workflows while the
adopting repository retains its own schedule, approvals, credentials, and
release policy.

```text
Scheduled monitor
        ↓
OCI digest and version resolution
        ↓
Reviewable Dockerfile update PR
        ↓
Approval and merge
        ↓
Build → test → scan → SBOM/provenance → publish → sign → GitHub Release
```

## Why Docker Image Lifecycle Automation

| Lifecycle problem | Platform capability |
|---|---|
| An upstream publisher rebuilds an unchanged tag | Digest-first detection catches the content change |
| Teams need control before a Dockerfile changes | Evidence-backed, reviewable update PRs |
| Release pipelines vary by repository | Reusable lifecycle contracts with repository-owned policy |
| Publishing an image is not sufficient evidence | Trivy, SPDX SBOMs, BuildKit provenance, and optional Cosign signing |
| Multiple OCI registries increase operational complexity | One registry abstraction for public, private, cloud, and generic OCI registries |

## Architecture

```text
Adopting repository
  Dockerfile + lifecycle policy + environment approvals
                    │
                    ▼
Reusable lifecycle workflows
  Monitor → update PR → build → test → scan → publish → sign → release
                    │
                    ▼
Composite lifecycle actions
  image reference · digest resolution · policy · version · registry auth
                    │
                    ▼
Shared scripts
  OCI protocol and deterministic parsing
```

Read the [architecture guide](docs/ARCHITECTURE.md) for contracts,
responsibilities, and compatibility guarantees.

## Quick start

1. Copy [`templates/minimal-monitor.yml`](templates/minimal-monitor.yml) to
   `.github/workflows/image-lifecycle.yml` in the image repository.
2. Replace `your-org/docker-image-lifecycle@v1` with
   `yaju-mahida/docker-image-lifecycle@v1`.
3. Set `DOCKERFILE_PATH`, `BASE_IMAGE_UPDATE_POLICY`, and optional reviewer
   variables.
4. Run the workflow manually in dry-run mode, then enable its schedule.
5. Move to [`templates/secure-release.yml`](templates/secure-release.yml)
   when you are ready to publish signed, verified images.

## Supported integration models

| Need | Use |
|---|---|
| Resolve an OCI tag to a digest | Root Marketplace Action (`yaju-mahida/docker-image-lifecycle@v1`) |
| Monitor an upstream image and create update PRs | `reusable-base-image-monitor.yml` |
| Build, verify, release, and publish an image | `reusable-docker-release.yml` |
| Adopt a lifecycle in stages | `templates/minimal-monitor.yml`, `templates/secure-release.yml`, or `templates/enterprise-release.yml` |
| Configure multiple/custom registries | `templates/docker-automation.yml` |

## Documentation

| Topic | Guide |
|---|---|
| Install and private-repository access | [Installation](docs/INSTALLATION.md) |
| Onboarding by adoption path | [Consumer Guide](docs/CONSUMER_GUIDE.md) |
| Lifecycle variables, policies, and release identifiers | [Configuration](docs/CONFIGURATION.md) |
| Digest-first monitoring | [Monitoring](docs/MONITORING.md) |
| Registry publishing | [Registries](docs/REGISTRIES.md) |
| Architecture | [Architecture](docs/ARCHITECTURE.md) |
| Public examples | [Examples](docs/EXAMPLES.md) |
| Marketplace listing and positioning | [Marketplace](docs/MARKETPLACE.md) |
| Product language and terminology | [Terminology](docs/TERMINOLOGY.md) |
| Planned lifecycle capabilities | [Roadmap](docs/ROADMAP.md) |
| Security policy | [Security](SECURITY.md) |

## Secure by default

Use immutable image digests or immutable release identifiers for deployment.
Mutable aliases such as `latest`, `stable`, and upstream tags are opt-in
convenience labels, never secure deployment inputs. Set `SIGN_IMAGES=true`
to keylessly sign every published image digest using Cosign and GitHub OIDC.

See [SECURITY.md](SECURITY.md) for reporting and responsibility guidance.

## Contributing and license

Contributions are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md), the
[Code of Conduct](CODE_OF_CONDUCT.md), and [Governance](GOVERNANCE.md).

Licensed under the [Apache License 2.0](LICENSE).