# Reusable Automation Reference

This file is retained as the stable documentation entry point for consumers
that used an earlier version of the project documentation.

The current official documentation is organized as follows:

- [Project overview and quick start](../README.md)
- [Architecture](ARCHITECTURE.md)
- [Installation](INSTALLATION.md)
- [Configuration and Repository Variables](CONFIGURATION.md)
- [Registry publishing](REGISTRIES.md)
- [Consumer onboarding](CONSUMER_GUIDE.md)
- [Base image monitoring](MONITORING.md)
- [Security policy](../SECURITY.md)
- [Examples](EXAMPLES.md)
- [FAQ](FAQ.md)
- [Migration](MIGRATION.md)
- [Contributing](../CONTRIBUTING.md)
- [Governance](../GOVERNANCE.md)
- [Marketplace metadata](MARKETPLACE.md)

## Reusable workflow contracts

### `reusable-base-image-monitor.yml`

The monitor workflow is called by a consumer-owned scheduled workflow. It
reads the consumer Dockerfile, checks the upstream image registry, applies
the selected update strategy, updates the Dockerfile, and creates a pull
request. It does not build, publish, tag, or create a release.

### `reusable-docker-release.yml`

The release workflow is called after a merge produces a `push` event on the
release branch. It calculates a consumer-controlled immutable release
identifier, builds requested platforms, runs tests, lints and scans the
image, generates an SBOM and provenance attestations, publishes to enabled
registries behind the configured Environment, then creates the Git tag and
GitHub Release with the SPDX SBOM attached. Creating the release last
prevents a release record from claiming an image that failed to publish.

When `SIGN_IMAGES=true`, each published image digest is keylessly signed
with Cosign and GitHub OIDC before the Git tag and GitHub Release are
created.

## Compatibility and pinning

Consumers should pin the reusable workflow reference to a major release for
managed compatible updates or to an immutable commit SHA for regulated
environments. Breaking changes to workflow inputs, outputs, security
defaults, or supported behavior require a new major version.
