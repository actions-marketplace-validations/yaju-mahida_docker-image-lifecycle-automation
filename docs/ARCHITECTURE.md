# Architecture Guide

## Design principles

1. **Thin consumers:** repositories own only their Dockerfile, schedule,
   variables, secrets, and a small caller workflow.
2. **Centralized orchestration:** lifecycle stages are implemented once in
   reusable workflows.
3. **Composable logic:** parsing, versioning, registry authentication, and config
   resolution are composite actions.
4. **Security by default:** scanning, provenance, SBOMs, OIDC, versioned action
   contracts,
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
        Build ──► Test ──► Scan ──► SBOM/Provenance ──► Publish ──► Sign ──► Release
```

## Stage contract

| Stage | Purpose | Inputs | Outputs | Dependencies | Reuse |
|---|---|---|---|---|---:|
| Monitor | Find upstream changes | Dockerfile, schedule, strategy | Update status, candidate tag | Upstream registry | 10/10 |
| Update PR | Propose evidence-backed Dockerfile change | Candidate tag, digest, reviewers | Branch and PR | GitHub token | 10/10 |
| Version | Calculate immutable release identifier | Release strategy, base tag/digest, Git tags | New tag | Git history | 9/10 |
| Build | Build requested platforms | Context, Dockerfile, platforms | Image artifact | Buildx, QEMU | 10/10 |
| Test | Run consumer smoke test | Candidate image, command | Pass/fail | Docker runtime | 8/10 |
| Verify | Lint, test, scan, generate SBOM/provenance | Dockerfile, image, threshold | Scan result, attestations | Hadolint, Trivy, BuildKit | 10/10 |
| Publish | Push and remotely verify OCI images | Registry matrix, credentials | Published immutable digest | Registry authentication, environment | 10/10 |
| Release | Create immutable Git tag and GitHub Release | Release identifier, published digest | Tag, release URL | GitHub token, publish success | 9/10 |

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
│   ├── ARCHITECTURE.md
│   ├── CONFIGURATION.md
│   ├── TERMINOLOGY.md
│   └── ...
├── examples
│   └── digest-monitor.yml
├── scripts
│   └── resolve-image-digest.sh
├── templates
│   ├── minimal-monitor.yml
│   ├── secure-release.yml
│   └── enterprise-release.yml
├── CONTRIBUTING.md
├── CODE_OF_CONDUCT.md
├── GOVERNANCE.md
├── README.md
└── SECURITY.md
```

`.github/actions/` contains reusable composite actions. This location is
deliberate: it preserves the published cross-repository action contract.
The reusable workflows orchestrate lifecycle stages, permissions, and
security gates. `scripts/` contains shared deterministic implementation
called by actions, never a second orchestration layer. `templates/` provides
progressive adoption paths, while `examples/` contains minimal runnable
demonstrations. Governance files at the repository root define contribution,
conduct, security, versioning, and release expectations.

Consumer-owned caller workflows are the only supported entry points. The
provider repository deliberately contains no scheduled or push-triggered
image workflows: it distributes reusable workflow contracts rather than
releasing an image of its own.

## Distribution contracts

```text
Marketplace action (root action.yml)
  └── Focused digest resolution for one-step adoption

Reusable workflows (.github/workflows)
  ├── Upstream Image Monitor
  └── Secure Container Release Lifecycle

Composite actions (.github/actions)
  ├── Deterministic lifecycle primitives
  └── Stable inputs, outputs, and failure behavior

Shared scripts (scripts/)
  └── OCI protocol mechanics shared by composite actions
```

The root action is intentionally narrow. It is the Marketplace discovery
surface and provides a quick, verifiable first result. The reusable workflows
provide the full lifecycle; they are not implicitly activated by the root
action.

## Compatibility policy

- `v1` is the supported compatibility line for the Marketplace action,
  reusable workflows, composite actions, and templates.
- Patch releases fix defects without changing documented contracts.
- Minor releases add backward-compatible inputs or capabilities.
- Breaking input/output, lifecycle, or secure-default changes require `v2`.
- Adopting repositories can pin `@v1` for managed compatibility or a full
  commit SHA for immutable high-assurance use.

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
