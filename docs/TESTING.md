# Testing Guide

Docker Image Lifecycle Automation uses layered testing so deterministic
lifecycle policy changes do not depend on mutable public registries or
production repositories.

## Test tiers

| Tier | Runs | Purpose |
|---|---|---|
| Pull request | Fixture suite, YAML/contracts, scripts | Deterministic action behavior |
| Main | Pull-request checks plus public OCI smoke | Confirms Marketplace digest resolution against a real registry |
| Nightly / protected | Main checks plus credentialed registry and publish lanes | Validates cloud registry, signing, and release integrations |

The declared tiers and registry support levels live in
[`test-fixtures/matrix.yml`](../test-fixtures/matrix.yml).

## Deterministic fixtures

Every directory containing `expected-results.yml` is one action contract.
The fixture runner:

1. Creates an isolated temporary workspace.
2. Copies the fixture Dockerfile/configuration.
3. Creates disposable Git history when a release identifier needs it.
4. Runs the action's shipped shell body.
5. Captures GitHub-style outputs.
6. Asserts exit code, expected outputs, and required diagnostics.

Run all deterministic fixtures:

```bash
python3 tests/run-fixtures.py
```

Run one suite:

```bash
python3 tests/run-fixtures.py --suite dockerfiles
```

## Fixture categories

| Suite | Coverage |
|---|---|
| `dockerfiles` | Standard, moving, versioned, non-versioned, digest-pinned, multi-stage, public/private registry, invalid, and build-argument rejection |
| `monitoring` | Digest and version policies, initial pinning, same-tag rebuilds, and rollback protection |
| `release-tags` | Increment gaps, SemVer, digest identifiers, initial releases, and collisions |
| `registries` | Scalar/config precedence, de-duplication, and missing target configuration |

Build-argument `FROM` references are an intentional expected failure in v1.
The platform does not claim argument resolution until it has a secure,
explicitly tested contract.

## Adding a fixture

1. Create a directory under the appropriate `test-fixtures/<suite>/` path.
2. Add the smallest input file needed, such as `Dockerfile`.
3. Add `expected-results.yml` with `action`, `inputs`, `expected`, and
   optional `history.tags`.
4. Run the relevant suite locally.
5. Keep expected values deterministic; do not hardcode a digest from a
   mutable public image.

## OCI and end-to-end testing

The public OCI smoke test resolves `docker.io/library/alpine:3.20` and
asserts an immutable digest plus multi-architecture metadata. It is an
integration signal, not a fixture dependency.

Credentialed publishing, GitHub Releases, environment approval behavior,
Cosign verification, and cloud-provider registries must run only in a
dedicated non-production fixture repository and registry namespace. Use
GitHub Environments, short-lived OIDC credentials, package-name allowlists,
and cleanup jobs. Never run those tests against a Marketplace release, a
production package namespace, or production credentials.

## Release gate

Before publishing a platform release, require:

1. All deterministic fixtures.
2. YAML, action metadata, template/workflow contract, and shell checks.
3. Public OCI smoke test.
4. Protected GHCR publish, remote digest, SBOM/provenance, and Cosign
   verification tests when those capabilities change.
