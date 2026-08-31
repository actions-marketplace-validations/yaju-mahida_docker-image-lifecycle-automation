# GitHub Marketplace Release Guide

## Marketplace listing

**Name:** Docker Image Lifecycle Automation

**Short description:**

> Resolve immutable OCI image digests and automate reviewed Docker base-image updates.

**Long description:**

Docker Image Lifecycle Automation is a digest-first OCI lifecycle platform
for GitHub Actions. It resolves mutable image tags to immutable manifest
digests, detects same-tag upstream rebuilds, and creates reviewable
Dockerfile update pull requests.

Use the included reusable workflows to build and test multi-platform images,
scan vulnerabilities, generate SPDX SBOMs and BuildKit provenance, sign
published digests with Cosign and GitHub OIDC, create releases, and publish
to cloud and generic OCI registries.

Start small with digest resolution. Adopt the complete lifecycle when you
need governed monitoring, review, release, and distribution.

The root Marketplace Action resolves a tag to a stable image digest. The
repository also provides reusable workflows for the complete image lifecycle.

## Categories

- Security
- Continuous integration

## Search keywords

`docker`, `container`, `oci`, `github-actions`, `dockerfile`, `base-image`,
`base-image-monitoring`, `docker-image-update`, `image-digest`,
`immutable-digest`, `container-security`, `supply-chain-security`, `sbom`,
`provenance`, `cosign`, `slsa`, `trivy`, `multi-platform`,
`container-registry`, `ghcr`, `docker-hub`, `platform-engineering`

## Marketplace Action

The root [`action.yml`](../action.yml) is the Marketplace entry point. It
resolves an OCI tag to an immutable digest and provides `digest`, `resolved`,
`media_type`, `is_multi_arch`, and `platforms` outputs. The action uses a
fixed OCI/Docker manifest `Accept` set to preserve multi-architecture index
digests.

**Branding:** `package` icon, `blue` color.

## Publish checklist

1. Make `yaju-mahida/docker-image-lifecycle-automation` public.
2. Confirm two-factor authentication is enabled for the publishing account.
3. Verify `LICENSE` and `NOTICE` are present and identify Apache-2.0.
4. Ensure `README.md` contains the root-action quick start and reusable
   workflow onboarding guidance.
5. Run the `Validate` workflow successfully on the release commit.
6. Run the `Release (SemVer)` workflow to create the initial `v1.0.0`
   release and moving `v1` major-version tag.
7. Confirm the release and moving major tag resolve to the same commit.
8. In the GitHub Release form, select **Publish this Action to the GitHub
   Marketplace** and accept the Marketplace Developer Agreement.
9. Use the listing text above and review the rendered Marketplace page before
   publishing.

## Versioning policy

The Marketplace Action and reusable workflow contracts follow Semantic
Versioning. Publish immutable release tags such as `v1.0.0`; keep `v1` as the
supported compatibility line. Breaking inputs, outputs, security defaults, or
workflow behavior require `v2`.

Consumer image release-identifier policies are independent of platform versioning.
They are configured through `RELEASE_TAG_STRATEGY` in the consumer repository.