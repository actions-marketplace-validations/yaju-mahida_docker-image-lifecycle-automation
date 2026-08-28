# Governance

## Project stewardship

Maintainers are responsible for architecture, security, releases,
documentation, and Marketplace operations. Contributors may propose changes
through issues and pull requests.

## Decision making

Routine changes are decided through pull-request review. Changes affecting
security boundaries, reusable workflow contracts, registry authentication,
or release behavior require at least two maintainer approvals when available.
Maintainers document the rationale for material decisions in the pull
request or an architecture decision record.

## Versioning

The project follows semantic versioning:

- Patch: bug fixes and documentation corrections
- Minor: backward-compatible capabilities and inputs
- Major: breaking workflow contracts, removed inputs, or changed security
  defaults

Consumers should pin a major tag for managed updates or an immutable SHA for
regulated workloads.

## Backward compatibility

Existing inputs and config-file behavior remain supported throughout a major
version whenever practical. Deprecations are documented for at least one
minor release before removal. Security fixes may require accelerated changes.

## Release policy

Releases require reviewed changes, passing validation, updated documentation,
and a changelog entry. Marketplace-facing changes must update the listing
metadata and examples.

## Support policy

Maintainers prioritize security defects, workflow breakages, and documented
supported scenarios. Provider-specific registry failures may depend on
external service availability and provider policy.
