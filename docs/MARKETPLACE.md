# GitHub Marketplace Metadata

## Name

**Docker Image Lifecycle**

## Short description

Secure, reusable GitHub Actions for monitoring, testing, scanning, releasing,
and publishing Docker images.

## Long description

Docker Image Lifecycle provides reusable workflows and composite actions for
the complete container image lifecycle. Consumer repositories keep a small
caller workflow and configure behavior with Repository Variables, Secrets,
and GitHub Environments.

The platform monitors upstream base images, creates reviewed Dockerfile update
pull requests, builds multi-platform images with Docker Buildx, runs
container tests, lints Dockerfiles, scans vulnerabilities with Trivy,
generates SPDX SBOMs, emits provenance attestations, creates GitHub Releases,
and publishes to popular OCI registries.

It supports public and private repositories, open-source projects, and
enterprise governance models. OIDC and environment approvals help reduce
long-lived credentials and prevent unattended production publication.

## Categories

- Continuous integration
- Deployment
- Security
- Package management
- Developer tools

## Keywords

`docker`, `containers`, `github-actions`, `reusable-workflow`, `devsecops`,
`docker-buildx`, `sbom`, `trivy`, `hadolint`, `oci`, `ghcr`, `ecr`, `acr`,
`docker-hub`, `supply-chain-security`

## Marketplace checklist

- Publish a public repository with an OSI-approved license.
- Add a clear action/workflow entry point and supported inputs.
- Include security and support documentation.
- Pin or document third-party action dependencies.
- Provide screenshots or workflow summary examples only after removing all
  credentials and private identifiers.
- Keep Marketplace description aligned with actual supported behavior.

## Branding

Use a simple container or pipeline icon, high contrast, accessible alt text,
and a neutral blue/green palette. Avoid provider-exclusive branding because
the platform supports multiple OCI registries.
