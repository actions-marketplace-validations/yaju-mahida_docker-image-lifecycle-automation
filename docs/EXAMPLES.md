# Examples

Replace `your-org/docker-image-lifecycle` with the public repository
reference used by your installation and pin a release tag or commit SHA.

## GHCR only

```text
PUBLISH_GHCR=true
GHCR_IMAGE=ghcr.io/organization-name/image-name
```

No registry Secret is required when `GITHUB_TOKEN` has package write access.

## Docker Hub only

```text
PUBLISH_DOCKERHUB=true
DOCKERHUB_IMAGE=organization-name/image-name
```

Secrets: `DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`.

## GHCR and Docker Hub

```text
PUBLISH_GHCR=true
GHCR_IMAGE=ghcr.io/organization-name/image-name
PUBLISH_DOCKERHUB=true
DOCKERHUB_IMAGE=organization-name/image-name
```

## ACR

```text
PUBLISH_ACR=true
ACR_IMAGE=your-registry.azurecr.io/image-name
```

Secrets: `ACR_USERNAME`, `ACR_PASSWORD`, unless using a provider-supported
federated identity design.

## ECR

```text
PUBLISH_ECR=true
ECR_IMAGE=123456789012.dkr.ecr.us-east-1.amazonaws.com/image-name
AWS_REGION=us-east-1
```

Secret: `AWS_ROLE_ARN`. Configure a restrictive GitHub OIDC trust policy.

## Custom registry

```text
PUBLISH_PRIVATE=true
PRIVATE_REGISTRY_HOST=registry.example.com
PRIVATE_IMAGE=registry.example.com/project/image-name
```

Secrets: `PRIVATE_REGISTRY_USERNAME`, `PRIVATE_REGISTRY_PASSWORD`.

## Multi-registry configuration file

Use `docs/docker-automation.yml.example` when a repository needs multiple
instances of a registry type. Keep credentials in Secrets; the file should
contain only non-sensitive image paths and hosts.
