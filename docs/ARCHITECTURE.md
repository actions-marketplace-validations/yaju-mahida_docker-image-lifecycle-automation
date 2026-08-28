# Architecture Guide

## Design principles

1. **Thin consumers:** repositories own only their Dockerfile, schedule,
   variables, secrets, and a small caller workflow.
2. **Centralized orchestration:** lifecycle stages are implemented once in
   reusable workflows.
3. **Composable logic:** parsing, versioning, registry login, and config
   resolution are composite actions.
4. **Security by default:** scanning, provenance, SBOMs, OIDC, action pinning,
   and environment approvals are first-class controls.
5. **Explicit ownership:** a consumer owns its schedule and merge policy; the
   platform owns workflow implementation and secure defaults.

## Lifecycle

```text
Scheduled monitoring
        │
        ▼
Read Dockerfile and inspect upstream registry
        │
        ▼
Compare current digest/version with eligible upstream tags
        │
        ├─ no update ──► finish
        │
        ▼
Update Dockerfile and create pull request
        │
        ▼
Review ──► approval ──► merge
                              │
                              ▼
                    push to release branch
                              │
                              ▼
        Build ──► Test ──► Scan ──► Publish ──► Sign ──► Release
```

## Stage contract

| Stage | Purpose | Inputs | Outputs | Dependencies | Reuse |
|---|---|---|---|---|---:|
| Monitor | Find upstream changes | Dockerfile, schedule, strategy | Update status, candidate tag | Upstream registry | 10/10 |
| Update PR | Propose Dockerfile change | Candidate tag, reviewers | Branch and PR | GitHub token | 10/10 |
| Version | Calculate immutable release identifier | Release strategy, base tag/digest, Git tags | New tag | Git history | 9/10 |
| Build | Build requested platforms | Context, Dockerfile, platforms | Image artifact | Buildx, QEMU | 10/10 |
| Test | Run consumer smoke test | Candidate image, command | Pass/fail | Docker runtime | 8/10 |
| Scan | Lint, scan, generate SBOM | Dockerfile, image, threshold | Scan result, SBOM | Hadolint, Trivy | 10/10 |
| Release | Create tag and GitHub Release | New tag, image reference | Tag, release URL | GitHub token | 9/10 |
| Publish | Push OCI images | Registry matrix, credentials | Published tags | Registry auth, environment | 10/10 |

## Repository architecture

```text
.
├── .github
│   ├── actions
│   │   ├── calculate-next-tag
│   │   ├── check-latest-upstream-tag
│   │   ├── check-paths-changed
│   │   ├── decide-base-image-update
│   │   ├── extract-base-image
│   │   ├── generate-release
│   │   ├── load-automation-config
│   │   ├── registry-login
│   │   ├── resolve-image-digest
│   │   └── resolve-registries
│   └── workflows
│       ├── reusable-base-image-monitor.yml
│       └── reusable-docker-release.yml
├── docs
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── GOVERNANCE.md
├── README.md
└── SECURITY.md
```

`actions/` contains reusable composite actions. The reusable workflows
orchestrate lifecycle stages and security gates. `docs/` contains public
guides and copyable consumer examples. Governance files at the repository
root define contribution, conduct, security, versioning, and release
expectations.

Consumer-owned caller workflows are the only supported entry points. The
provider repository deliberately contains no scheduled or push-triggered
image workflows: it distributes reusable workflow contracts rather than
releasing an image of its own.

## Configuration precedence

```text
Explicit workflow_call input
          ↓
Repository Variable
          ↓
Optional .github/docker-automation.yml
          ↓
Platform default
```

GitHub has no `vars: inherit` for reusable workflows, so consumer caller
workflows explicitly forward variables as `var-*` inputs.
