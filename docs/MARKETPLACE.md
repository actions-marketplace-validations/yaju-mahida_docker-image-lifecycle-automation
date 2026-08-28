# GitHub Marketplace Release Guide

## Marketplace listing

**Name:** Docker Image Lifecycle

**Short description:**

> Resolve OCI image digests and automate secure Docker image lifecycles with GitHub Actions.

**Long description:**

Docker Image Lifecycle is an OCI-native GitHub Actions platform for
content-addressed base-image monitoring, reviewable Dockerfile updates,
multi-platform builds, testing, vulnerability scanning, SPDX SBOM generation,
keyless image signing, releases, and multi-registry publishing.

The root Marketplace Action resolves a tag to a stable image digest. The
repository also provides reusable workflows for the complete image lifecycle.

## Categories

- Continuous integration
- Security
- Publishing
- Utilities

## Search keywords

`docker`, `container`, `oci`, `github-actions`, `dockerfile`, `base-image`,
`image-monitoring`, `container-security`, `devsecops`, `supply-chain-security`,
`sbom`, `cosign`, `slsa`, `trivy`, `multi-architecture`, `multi-platform`,
`container-registry`, `ghcr`, `docker-hub`, `platform-engineering`

## Marketplace Action

The root [`action.yml`](../action.yml) is the Marketplace entry point. It
resolves an OCI tag to an immutable digest and provides `digest`, `resolved`,
`media_type`, `is_multi_arch`, and `platforms` outputs. The action uses a
fixed OCI/Docker manifest `Accept` set to preserve multi-architecture index
digests.

**Branding:** `package` icon, `blue` color.

## Publish checklist

1. Make `yaju-mahida/docker-image-lifecycle` public.
2. Confirm two-factor authentication is enabled for the publishing account.
3. Verify `LICENSE` and `NOTICE` are present and identify Apache-2.0.
4. Ensure `README.md` contains the root-action quick start and reusable
   workflow onboarding guidance.
5. Run the `Validate` workflow successfully on the release commit.
6. Create an annotated `v1.0.0` release tag and GitHub Release.
7. Create/update the moving `v1` major-version tag to the same release.
8. In the GitHub Release form, select **Publish this Action to the GitHub
   Marketplace** and accept the Marketplace Developer Agreement.
9. Use the listing text above and review the rendered Marketplace page before
   publishing.

## Versioning policy

The Marketplace Action and reusable workflow contracts follow Semantic
Versioning. Publish immutable release tags such as `v1.0.0`; keep `v1` as the
supported compatibility line. Breaking inputs, outputs, security defaults, or
workflow behavior require `v2`.

Consumer image-release strategies are independent of platform versioning.
They are configured through `RELEASE_TAG_STRATEGY` in the consumer repository.