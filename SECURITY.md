# Security Policy

## Security objectives

This project treats Docker build automation as a software supply-chain
component. The platform is designed to reduce credential exposure, detect
known vulnerabilities, produce audit evidence, and require explicit
promotion controls.

## Controls

- Least-privilege GitHub Actions permissions
- OIDC federation for AWS ECR where available
- Environment approvals for production publication
- Hadolint Dockerfile analysis
- Trivy vulnerability scanning
- SPDX SBOM artifacts
- BuildKit provenance and SBOM attestations
- Immutable release tags and digest references; mutable aliases are opt-in
- Optional keyless Cosign signing of published image digests with GitHub OIDC
- Pinned third-party action versions in production
- Pull-request review before monitored base-image changes release

Image signing is recommended for production deployments. Integrators should
add a keyless signing step using an approved identity and transparency-log
policy; signing is intentionally governed by the consumer's trust model.

## Secret handling

Use GitHub Secrets or organization/environment Secrets for credentials. Use
short-lived, repository-scoped tokens. Never log secrets, interpolate them
into image labels, or commit them to configuration.

## Reporting a vulnerability

Do not open a public issue for an undisclosed vulnerability. Use the
repository's GitHub Security Advisories feature or the private security
reporting channel configured by maintainers. Include affected versions,
reproduction steps, impact, and a suggested mitigation when available.

Maintainers should acknowledge reports promptly, coordinate a fix, publish
an advisory when appropriate, and credit reporters who opt in.

## Consumer responsibility

Consumers remain responsible for Dockerfile content, base image trust,
registry policies, runner hardening, environment reviewers, and the
severity threshold they select. A passing scan is not a guarantee that an
image is secure.
