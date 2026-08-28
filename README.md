# Docker Image Lifecycle

Reusable GitHub Actions and workflows for safely monitoring, building,
testing, scanning, releasing, and publishing Docker images.

[![GitHub Marketplace](https://img.shields.io/badge/GitHub%20Marketplace-Docker%20Image%20Automation-blue?logo=github)](https://github.com/marketplace)
[![Docker](https://img.shields.io/badge/container-Docker-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Security](https://img.shields.io/badge/security-DevSecOps-green)](SECURITY.md)

## Why this project exists

Docker image repositories often duplicate the same workflow logic: checking
upstream base images, opening update pull requests, building multiple
architectures, scanning images, creating releases, and publishing to one or
more registries. This project centralizes that lifecycle while keeping
repository-specific settings in the consumer repository.

The recommended integration is a thin consumer workflow calling reusable
workflows from this repository. Repository Variables are the primary
configuration surface; an optional YAML file remains available for complex
multi-registry configurations.

## Capabilities

- Scheduled base image monitoring and Dockerfile update pull requests
- Patch, minor, and major upstream version strategies
- Consumer-owned schedules and release triggers
- Consumer-controlled immutable release identifiers: upstream, increment,
  prefix, release, SemVer, date-prefix, or digest-derived
- Multi-platform Docker Buildx builds
- Container smoke tests
- Hadolint Dockerfile linting
- Trivy vulnerability scanning
- SPDX SBOM generation
- BuildKit provenance and SBOM attestations
- GitHub Releases, generated changelogs, and attached SPDX SBOMs
- Environment-gated publication
- GHCR, Docker Hub, ACR, ECR, Quay, Harbor, Artifactory, GitLab Registry,
  DigitalOcean Container Registry, OCIR, and generic OCI registries
- OIDC authentication for cloud registries where supported

## Architecture

```text
Consumer repository
  ├─ Dockerfile
  ├─ Repository Variables and Secrets
  └─ thin caller workflow
          │
          ▼
  reusable-base-image-monitor
          │
          ├─ inspect upstream image
          ├─ compare digest/version
          └─ open update pull request
                    │
              review and merge
                    │
                    ▼
             push to release branch
                    │
                    ▼
  reusable-docker-release
          ├─ build
          ├─ test
          ├─ lint and scan
          ├─ generate SBOM/provenance
          ├─ publish immutable OCI image
          ├─ optionally sign the published digest
          └─ tag and create GitHub Release with the SBOM attached
```

The monitor never invokes the release workflow directly. A successful merge
to the release branch produces the authoritative `push` event.

## Quick start

1. Copy [`docs/consumer-workflow-example.yml`](docs/consumer-workflow-example.yml)
   to `.github/workflows/docker-automation.yml` in your image repository.
2. Replace `your-org/docker-image-lifecycle` with the repository reference
   you use and pin a release such as `@v1` or an immutable commit SHA.
3. Set Repository Variables such as `DOCKERFILE_PATH`, `BUILD_PLATFORMS`,
   `IMAGE_NAME`, and the relevant `PUBLISH_*` values.
4. Add only the registry Secrets required by the enabled targets.
5. Configure the named GitHub Environment if publication requires approval.
6. Run the workflow manually in dry-run mode before enabling production
   publication.

See [the installation guide](docs/INSTALLATION.md) and
[the configuration guide](docs/CONFIGURATION.md) for complete details.

## Documentation

| Topic | Guide |
|---|---|
| Architecture and lifecycle | [Architecture Guide](docs/ARCHITECTURE.md) |
| Installation | [Installation Guide](docs/INSTALLATION.md) |
| Variables and secrets | [Configuration Guide](docs/CONFIGURATION.md) |
| Registry setup | [Registry Publishing Guide](docs/REGISTRIES.md) |
| Consumer onboarding | [Consumer Guide](docs/CONSUMER_GUIDE.md) |
| Base image monitoring | [Monitoring Guide](docs/MONITORING.md) |
| Security | [Security Documentation](SECURITY.md) |
| Examples | [Examples](docs/EXAMPLES.md) |
| FAQ | [FAQ](docs/FAQ.md) |
| Migration | [Migration Guide](docs/MIGRATION.md) |
| Contributing | [CONTRIBUTING.md](CONTRIBUTING.md) |
| Governance | [GOVERNANCE.md](GOVERNANCE.md) |
| Marketplace listing | [Marketplace Metadata](docs/MARKETPLACE.md) |

## Support and compatibility

The workflows run on GitHub-hosted Ubuntu runners and use Docker Buildx.
Consumers should use a supported GitHub Actions plan with workflow calls,
Environments, and the permissions required by their selected registries.

The platform is designed for public repositories, private repositories, and
organization-managed enterprise repositories. Pin action references, use
least-privilege permissions, and test upgrades in a non-production consumer
before adopting a new major version.

## Contributing

Bug reports, documentation improvements, registry integrations, and workflow
hardening are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) before opening
a pull request.

## License

Add an OSI-approved license file before publishing this repository. MIT or
Apache-2.0 are common choices for an automation library; the maintainers
should select and document the license that matches the project's ownership
and contribution policy.
