# Installation Guide

## Prerequisites

- A GitHub repository containing a Dockerfile
- GitHub Actions enabled
- A release branch, normally `main`
- Docker Buildx-compatible GitHub-hosted or self-hosted runner
- Permission to configure Repository Variables, Secrets, and Environments
- Registry account or OIDC trust policy for every publication target

## Open-source deployment

Use the example caller workflow, set variables in the repository Settings
page, and use `GITHUB_TOKEN` for GHCR where the package permissions allow it.
Start with `workflow_dispatch` dry runs and enable the schedule and push
triggers after reviewing the output.

## Enterprise deployment

Pin the platform workflow to an immutable commit SHA or approved release tag.
Manage variables, secrets, Environment reviewers, and OIDC trust policies
through the organization's approved infrastructure-as-code process. Use
organization or enterprise rulesets to require workflow review, CODEOWNERS
approval, signed commits, and successful security checks.

## Private Repository Access

If the automation repository (the one containing
`reusable-base-image-monitor.yml`, `reusable-docker-release.yml`, and the
`.github/actions/*` composite actions) is **private**, GitHub blocks every
other repository from calling its reusable workflows or composite actions
by default — including other private repositories you own. Referencing it
without granting access produces an error similar to:

```text
Invalid workflow file: .github/workflows/docker-automation.yml#L85
error parsing called workflow
".github/workflows/docker-automation.yml"
-> "owner/docker-image-lifecycle-automation/.github/workflows/reusable-base-image-monitor.yml@v1"
: workflow was not found.
```

To fix this, grant access from the **automation repository's** settings,
not the consumer repository:

1. Open the automation repository (e.g. `owner/docker-image-lifecycle-automation`).
2. Go to **Settings → Actions → General**.
3. Scroll to the **Access** section.
4. Select the option that grants access to other repositories you (or your
   organization) own:
   - Personal account: **"Accessible from repositories owned by the user
     '`<username>`'"**
   - Organization account: **"Accessible from repositories in the
     '`<organization>`' organization"**
5. Save.

Notes and constraints:

- **Both repositories must be owned by the same personal account or the
  same organization.** Private cross-account access (a private repo under
  one user calling a private repo under a different user or org) is not
  supported by GitHub at all, regardless of this setting.
- This setting must be changed on the **automation repository**, not the
  consumer repository. Changing consumer-side settings has no effect on
  this error.
- Also confirm the `@v1` (or whichever ref you used in `uses:`/
  `automation-ref`) actually exists as a tag, branch, or commit SHA on the
  automation repository. An access-granted repository will still fail with
  the same "workflow was not found" error if the ref itself does not exist
  — while validating this, temporarily point at `@main` or a specific
  commit SHA instead of an unreleased tag.
- Both repositories must have GitHub Actions enabled.

See GitHub's documentation on
[reusing workflows](https://docs.github.com/actions/learn-github-actions/reusing-workflows#access-to-reusable-workflows)
for the current access model.

## First-run checklist

1. Copy the consumer workflow.
2. Set `DOCKERFILE_PATH`, `BUILD_CONTEXT`, and `BUILD_PLATFORMS`.
3. Set one `PUBLISH_*` variable and its image variable.
4. Add the matching registry credentials.
5. Configure `DEPLOYMENT_ENVIRONMENT`.
6. Run a dry run.
7. Review scan, SBOM, and summary output.
8. Enable production publication only after approval.
