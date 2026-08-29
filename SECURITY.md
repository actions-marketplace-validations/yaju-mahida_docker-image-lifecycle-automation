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
- Versioned third-party action dependencies; full commit-SHA pinning is
  recommended for high-assurance environments
- Pull-request review before monitored base-image changes release

Image signing is recommended for production deployments. The secure and
enterprise templates enable keyless signing by default. Integrators must
define an approved issuer, certificate identity, and transparency-log policy
for verification; signing is intentionally governed by the adopting
repository's trust model.

## Trust boundaries

- A digest identifies exact registry content, but does not by itself establish
  who published it. Verify provenance and signatures before production
  promotion where your policy requires it.
- `latest`, `stable`, and upstream tags are mutable aliases. Deploy immutable
  digests or immutable release identifiers instead.
- The platform produces SBOM and BuildKit provenance attestations during
  secure releases. Verification policy is repository-owned and should be
  enforced before deployment.
- Keep upstream read credentials read-only and separate from registry publish
  credentials.

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
