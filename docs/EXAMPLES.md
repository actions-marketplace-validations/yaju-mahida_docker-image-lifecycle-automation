# Public examples

All examples use the generic `your-org/docker-image-lifecycle@v1` reference.
Replace `your-org` with the owner of your approved platform fork or the public
upstream repository.

## Marketplace digest resolver

[`examples/digest-monitor.yml`](../examples/digest-monitor.yml) resolves a
public OCI image to an immutable digest. It is the smallest useful adoption
path and works independently of the full lifecycle workflows.

## Full lifecycle consumer

[`templates/consumer-workflow.yml`](../templates/consumer-workflow.yml)
provides a consumer-owned schedule and release-branch trigger for the
reusable monitor and release workflows.

## Advanced configuration

[`templates/docker-automation.yml`](../templates/docker-automation.yml)
shows the optional configuration file for consumers with multiple registry
instances or reviewable nested configuration.

## Registry targets

Use the corresponding `PUBLISH_<TYPE>` and `<TYPE>_IMAGE` Repository
Variables documented in [Registry Publishing](REGISTRIES.md). Credentials
belong in GitHub Secrets or protected Environments, never in examples.