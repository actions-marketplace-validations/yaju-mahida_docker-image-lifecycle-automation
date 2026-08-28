# Frequently Asked Questions

## Why do I get "workflow was not found" when calling a private automation repository?

The automation repository containing the reusable workflows and composite
actions must explicitly grant cross-repository Actions access before any
other repository — including one you own — can call it. Go to the
automation repository's **Settings → Actions → General → Access** and
select the option that allows access from repositories owned by your user
or organization. Both repositories must be owned by the same account;
cross-account private access is never supported. Also verify the ref used
in `uses:`/`automation-ref` (e.g. `@v1`) actually exists. See
[Private Repository Access](INSTALLATION.md#private-repository-access) for
full steps.

## Does the monitor build or publish an image?

No. It only checks the upstream image and creates a pull request. Publication
starts after a reviewed change is merged into the release branch.

## Why is the release trigger `push`?

A merge to the protected release branch creates a `push` event. This is the
authoritative post-approval signal and avoids duplicate or premature releases.

## Can the schedule be stored in a Repository Variable?

No. GitHub evaluates `schedule.cron` from static workflow YAML. The consumer
repository owns the cron expression.

## Can I use a timezone in cron?

No. GitHub cron is UTC. Convert local time and account for daylight-saving
changes separately.

## Why do reusable workflows need many `var-*` inputs?

GitHub supports `secrets: inherit` but does not provide `vars: inherit`.
Variables must therefore be forwarded explicitly by the caller.

## What happens when a variable is empty?

The workflow falls back to the optional configuration file and then the
documented platform default.

## How do I publish to two ACR instances?

Use the optional `release.registries` array. Scalar variables support one
target per registry type.

## Are Repository Variables secure for passwords?

No. Variables are not a secret store. Put credentials in GitHub Secrets or
Environment/organization Secrets.

## Does `latest` replace immutable tags?

No. The workflow does not publish `latest` implicitly. It always publishes
the configured immutable release identifier; use that tag or the image
digest for reproducible deployments. Set `PUBLISH_UPSTREAM_TAG_ALIAS=true`
only when an intentionally mutable upstream-tag alias is required.

## Can I keep the upstream tag unchanged?

Yes. Set `PUBLISH_UPSTREAM_TAG_ALIAS=true` to publish an alias such as
`your-image:php8.4-apache` after the immutable release image has been
published. Do not use `UPSTREAM_TAG` as the only release identifier for a
tag that can be rebuilt: Git tags are immutable but OCI tags are mutable.
Use `BASE_TAG_INCREMENT` or `DIGEST` for the immutable release record.

## How do I sign published images?

Set `SIGN_IMAGES=true`. The platform uses keyless Cosign signing with GitHub
OIDC and signs each published digest, never a mutable tag. The consumer
caller must retain the supplied `id-token: write` permission.

## Does a passing Trivy scan guarantee security?

No. Vulnerability databases have coverage and timing limits. Combine scans
with trusted base images, review, signing, runtime controls, and update
policies.

## How do I pause monitoring?

Set `BASE_IMAGE_MONITOR_ENABLED=false`. The schedule still wakes the workflow,
but the monitor exits without creating a pull request.

## Why did a documentation-only change not release?

The caller may have a static `paths-ignore` filter and the reusable workflow
also applies the dynamic `PATHS_IGNORE` gate. Check both settings.

## Why did publishing fail after authentication?

Check image path, repository permissions, Environment approval status, token
scope, registry availability, and whether the image repository already exists.

## How do I troubleshoot a failed workflow?

Run a dry run, inspect the workflow summary, confirm resolved configuration,
verify the candidate image locally, and review registry/provider logs. Do not
print credentials while debugging.

## Can I use a self-hosted runner?

Yes, if it provides Docker, Buildx, required network access, and adequate
isolation. Harden and monitor self-hosted runners carefully.

## Can I sign images?

The workflow produces provenance and SBOM attestations. Add a consumer-
approved signing step using your identity, keyless trust, and verification
policy.

## How are breaking changes handled?

Breaking workflow contracts require a new major version. Existing major
versions should remain supported according to the governance policy.

## Is this project suitable for enterprises?

Yes. Pin immutable references, manage configuration as code, use Environment
reviewers, enforce rulesets, use OIDC, and centralize approved versions.
