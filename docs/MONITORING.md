# Base Image Monitoring Guide

The monitor is the first lifecycle entry point. It runs on a consumer-owned
schedule, reads the base image reference from the Dockerfile, resolves that
reference against the upstream registry, and decides whether an update
should be proposed.

```text
Consumer schedule
        ↓
Monitor workflow
        ↓
Signal collection (digest + version)
        ↓
Policy decision
        ↓
Dockerfile update pull request
        ↓
Review and approval
        ↓
Merge to release branch
        ↓
push event
        ↓
Release workflow
```

The monitor never calls the release workflow directly. The merge-generated
`push` event is authoritative: it prevents a release before review and
avoids duplicate dispatch paths.

## Why digest-first

Tag comparison alone is not a reliable update signal. Publishers routinely
rebuild an image and republish it under the **same tag** — for security
fixes, base image updates, package refreshes, or reproducible rebuilds. Two
different tags can also point at the same image:

```text
example/app:1.2-runtime   ─┐
                           ├─→ sha256:4120511b044f...
example/app:runtime       ─┘
```

A monitor that only compares tag strings sees "no change" in both
situations. The digest is the only signal that is both content-addressed
and universally available, so it is the primary mechanism. Version
comparison is a secondary signal that classifies *how significant* a change
is and whether the tag itself should move.

## Detection signals, in priority order

1. **Digest change** — the current pinned digest versus the digest the
   tag resolves to now. Always treated as an update.
2. **Version change** — a newer eligible upstream tag, classified as
   `patch`, `minor`, or `major` and filtered by the update strategy.
3. **Registry metadata** (`last_updated`, `pushed_at`) — not used as a
   decision input. It is inconsistently exposed, non-standard across
   registries, and trivially forgeable; it is treated as evidence only.
4. **Manifest structure** — the index (manifest list) digest is the
   canonical identity for multi-architecture images.

## Digest pinning is the state

The monitor writes the base image reference back to the Dockerfile as
`image:tag@sha256:...`. This is deliberate:

- The digest is simultaneously the build input and the monitor's stored
  state, so the two cannot drift apart.
- The change is visible and reviewable in the pull request diff.
- It survives forks and repository transfers; no external cache or
  repository variable is required.
- It closes the window between detection and build, in which an upstream
  tag could otherwise be repointed.
- The Dockerfile's git history becomes a tamper-evident digest ledger,
  which is what makes rollback detection possible.

For multi-architecture images the **index digest** is pinned. A
per-platform digest is never written back, because doing so would silently
reduce the image to a single architecture. Per-platform digests appear in
the pull request body as evidence only.

## Registry support

Digest resolution uses the OCI Distribution Specification directly: it
issues a `HEAD` against the manifest endpoint, discovers how to
authenticate from the registry's own `WWW-Authenticate` challenge, and
reads the `Docker-Content-Digest` response header, falling back to hashing
the raw manifest body when a registry omits that header.

Because the challenge is self-describing, the same code path works against
Docker Hub, GitHub Container Registry, Quay, Harbor, Artifactory, GitLab
Registry, Oracle Registry, and any other conformant OCI registry without
per-registry configuration. Only Azure Container Registry and Amazon ECR
require a thin credential-exchange adapter, and only when reading a private
base image.

The `Accept` header set sent with each request is a versioned contract:
OCI image index, Docker manifest list, OCI image manifest, Docker image
manifest. Requesting a narrower set causes some registries to return a
converted single-architecture manifest with a *different* digest, which
would produce phantom updates.

## Tag categories

| Category | Example | Primary signal | Notes |
|---|---|---|---|
| Versioned | `1.2.3-runtime` | version, then digest | Both signals reliable. |
| Moving | `latest`, `stable`, `runtime` | digest only | Version signal is meaningless; auto-merge is blocked. |
| Date-based | `2026.08.01` | digest, then version | Ordering is lexical, not semantic. |
| Digest-pinned | `image@sha256:...` | digest only | No tag to compare; fully deterministic. |
| Custom | `prod`, `golden` | digest only | Treated as moving tags. |

## Update policies

Set with the `BASE_IMAGE_UPDATE_POLICY` repository variable or the
`monitor.update_policy` configuration key.

| Policy | Digest change | Version bump | Trade-off |
|---|---|---|---|
| `DIGEST_AND_VERSION` | update | update | **Default.** Complete coverage; more pull requests. |
| `DIGEST_ONLY` | update | ignored | Never leaves the current tag; misses new releases. |
| `VERSION_ONLY` | ignored | update | Legacy behaviour; misses rebuild-only security fixes. |
| `STRICT_SEMVER` | update | semver-parseable only | Predictable; ignores date-style versions. |
| `ALWAYS_UPDATE` | update | update | Re-pins every run. Testing only. |

## Decision outcomes

Each run produces one of three outcomes and a classification:

- Outcome — `UPDATE`, `REVIEW`, or `IGNORE`
- Kind — `REBUILD` (same tag, new digest), `VERSION_UPDATE` (new tag),
  `REPIN` (an unpinned reference gained a digest), or `NONE`

| Digest changed | Version changed | Outcome | Kind |
|---|---|---|---|
| no | no | `IGNORE` | `NONE` |
| yes | no | `UPDATE` | `REBUILD` |
| no | yes | `UPDATE` | `VERSION_UPDATE` |
| yes | yes | `UPDATE` | `VERSION_UPDATE` |
| reverts to a previously seen digest | any | `REVIEW` | — |
| n/a (no digest recorded yet) | no | `UPDATE` | `REPIN` |

The first run against an unpinned Dockerfile always produces a `REPIN`
pull request that adds the digest without changing the tag.

## Security behaviour

Certain conditions override the policy result after it has been computed:

- **Digest rollback** — if the newly resolved digest matches a digest that
  appears earlier in the Dockerfile's git history, the change is flagged
  `REVIEW` rather than applied. This detects a mutable tag being pointed
  back at a superseded, potentially vulnerable image.
- **Major version changes** always block auto-merge.
- **Moving tags** always block auto-merge, because there is no version
  evidence to review.
- **An empty or unresolvable digest** never produces a commit; the run
  fails rather than writing an unpinned reference.

Registry read credentials, when supplied, are read-only and are masked in
logs. They must never be publishing credentials.

## Pull request lifecycle

The workflow creates or updates an `automation/base-image-*` branch, opens
a pull request containing a before/after digest table, assigns configured
reviewers and assignees, and can request GitHub native auto-merge.
Auto-merge additionally requires repository support, branch protection, and
required checks — and is suppressed whenever the decision engine sets the
block flag.

## Schedule limitations

Hourly, daily, weekly, monthly, and custom cron schedules are supported by
changing the consumer caller's static `schedule.cron`. GitHub does not
support variable-driven cron or timezone-aware cron. Daylight-saving changes
must be handled by updating the consumer workflow or accepting a small UTC
drift.
