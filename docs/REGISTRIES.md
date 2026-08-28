# Registry Publishing Guide

The publish job creates a matrix entry for every enabled registry. Each
entry receives an immutable version tag. Configure GitHub
Environment approvals before production publication.

## GHCR

Set `PUBLISH_GHCR=true` and `GHCR_IMAGE=ghcr.io/organization-name/image-name`.
The workflow uses the repository `GITHUB_TOKEN`; grant `packages: write` and
ensure package access is configured.

## Docker Hub

Set `PUBLISH_DOCKERHUB=true` and `DOCKERHUB_IMAGE=organization-name/image-name`.
Add `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` as Secrets. Use a least-
privilege access token rather than a password.

## Azure Container Registry

Set `PUBLISH_ACR=true` and `ACR_IMAGE=your-registry.azurecr.io/image-name`.
For username/password login, add `ACR_USERNAME` and `ACR_PASSWORD`. Prefer
short-lived federation or workload identity where your ACR design supports
it.

## Amazon ECR

Set `PUBLISH_ECR=true`, `ECR_IMAGE=account.dkr.ecr.region.amazonaws.com/image-name`,
and `AWS_REGION=region`. Add `AWS_ROLE_ARN` and configure GitHub OIDC trust
with a restrictive repository, branch, and audience policy. Do not store
long-lived AWS access keys in GitHub Secrets.

## Quay

Set `PUBLISH_QUAY=true` and `QUAY_IMAGE=quay.io/organization-name/image-name`.
Add `QUAY_USERNAME` and `QUAY_TOKEN`.

## Harbor, Artifactory, GitLab, DigitalOcean, and OCIR

Set the matching `PUBLISH_*` and image variables. Provide a registry host
variable where required and add the provider's username/token Secrets. Use
short-lived tokens, repository-scoped permissions, and protected
Environments.

## Generic OCI and private registries

Set `PUBLISH_PRIVATE=true`, `PRIVATE_REGISTRY_HOST`,
`PRIVATE_IMAGE`, `PRIVATE_REGISTRY_USERNAME`, and
`PRIVATE_REGISTRY_PASSWORD`. The registry must implement the Docker Registry
authentication flow supported by `docker/login-action`.

## Multiple registry instances

Scalar variables represent one target per registry type. Use the optional
`release.registries` array for multiple ACR or ECR targets, custom hosts, or
region-sharded publication. Variables take precedence for a type already
enabled through `PUBLISH_<TYPE>`.

## Reading the upstream base image (monitoring)

Publishing credentials and monitoring credentials are separate concerns.

The monitor resolves the base image digest through the OCI Distribution
Specification, discovering how to authenticate from the registry's own
`WWW-Authenticate` challenge. No configuration is needed for a public base
image on any conformant registry.

Provide credentials only when the base image is private, or to lift
anonymous pull rate limits:

- `registry-username` input on the monitor workflow
- `REGISTRY_PASSWORD` secret (optional)

These must be **read-only** credentials scoped to the upstream repository.
Never reuse a publishing token here. Tokens are masked in workflow logs.

Azure Container Registry and Amazon ECR require a short-lived
credential exchange when the base image is private; supply an ACR token or
an ECR authorization token as `REGISTRY_PASSWORD`.
