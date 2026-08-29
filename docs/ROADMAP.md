# Product Roadmap

Docker Image Lifecycle Automation is developed as a lifecycle platform, not
as a collection of unrelated Docker actions. The roadmap prioritizes
trustworthy digest monitoring and an excellent adopting-repository experience
before organization-wide governance features.

## v1: Trusted lifecycle core

- Stable Marketplace action and `v1` compatibility line.
- Digest-first upstream image monitoring, including same-tag rebuilds.
- Evidence-backed Dockerfile update pull requests.
- Multi-platform build, smoke test, scan, SPDX SBOM, provenance, signing,
  release, and multi-registry publication.
- Progressive templates for digest resolution, monitoring, secure release,
  and environment-gated release.
- Published OCI registry support matrix and action/workflow compatibility
  contract.

## v1.x: Adoption and operations

- More actionable dry-run and pull-request evidence.
- Contract and OCI integration fixtures for public and private registries.
- Migration guides for manual Docker workflows, Dependabot, and Renovate.
- Registry-specific operational guidance and troubleshooting.
- Release-note and changelog automation improvements.

## v2: Governed lifecycle policy

- Versioned policy-as-code for trusted upstream registries, allowed
  namespaces, required digest pinning, severity gates, and signing policy.
- Verification gates for published-image digest, provenance, and signatures.
- Promotion channels and immutable rollback workflow.
- Compliance evidence bundles.

## v3: Platform engineering scale

- Organization-wide upstream-image exposure inventory.
- Upstream image to adopting-repository dependency graph.
- Central policy bundles with repository-level exceptions.
- Lifecycle reporting and audit integrations.

## Explicit non-goals

- Replacing Renovate or Dependabot as a general dependency manager.
- Requiring a SaaS control plane for open-source use.
- Treating mutable tags as production deployment identities.
- Hiding approvals, credentials, or release policy in a central platform
  repository.
