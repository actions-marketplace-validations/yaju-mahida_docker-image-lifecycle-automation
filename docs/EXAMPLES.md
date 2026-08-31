# Public examples

All examples use the `yaju-mahida/docker-image-lifecycle-automation@v1`
reference. Replace the owner if you are consuming an approved fork rather
than the upstream repository.

## Marketplace digest resolver

[`examples/digest-monitor.yml`](../examples/digest-monitor.yml) resolves a
public OCI image to an immutable digest. It is the smallest useful adoption
path and works independently of the full lifecycle workflows.

## Progressive lifecycle templates

Choose one template rather than adapting a single large workflow:

- [`templates/minimal-monitor.yml`](../templates/minimal-monitor.yml) for
  digest-first monitoring and reviewable update pull requests.
- [`templates/secure-release.yml`](../templates/secure-release.yml) for a
  multi-platform, signed release to GHCR.
- [`templates/enterprise-release.yml`](../templates/enterprise-release.yml)
  for environment-gated, multi-registry releases with OIDC support.

## Advanced configuration

[`templates/docker-automation.yml`](../templates/docker-automation.yml)
shows the optional configuration file for consumers with multiple registry
instances or reviewable nested configuration.

## Registry targets

Use the corresponding `PUBLISH_<TYPE>` and `<TYPE>_IMAGE` Repository
Variables are documented in [Lifecycle Policy and Configuration](CONFIGURATION.md).
Credentials belong in GitHub Secrets or protected Environments, never in
examples.