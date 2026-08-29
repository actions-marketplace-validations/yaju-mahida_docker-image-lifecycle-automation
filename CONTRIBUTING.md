# Contributing

Thank you for improving Docker Image Lifecycle Automation.

## Development process

1. Open an issue for significant behavior, registry, security, or API
   changes.
2. Create a focused branch from the default branch.
3. Make the smallest complete change and update affected documentation.
4. Validate YAML syntax and embedded scripts locally.
5. Open a pull request with a clear problem statement, implementation
   summary, security impact, and validation details.

## Standards

- Use clear, portable Bash with `set -euo pipefail`.
- Preserve explicit error handling; do not hide failures with broad catches.
- Keep reusable workflow inputs backward compatible within a major version.
- Pin third-party actions to reviewed tags or SHAs.
- Avoid organization-specific names, URLs, credentials, and assumptions.
- Prefer ASCII in workflow and action metadata.
- Document new variables, secrets, defaults, and limitations.

## Pull request review

Changes are reviewed for correctness, security, compatibility, portability,
documentation quality, and operational impact. Registry integrations must
explain authentication, required permissions, and failure behavior.

Breaking input/output or default changes require a new major version and a
migration note.

## Release process

Maintainers merge reviewed changes, validate representative consumer
configurations, update release notes, and publish a signed or otherwise
verified release tag according to the project's release policy. Marketplace
metadata and examples must be updated with user-visible changes.
