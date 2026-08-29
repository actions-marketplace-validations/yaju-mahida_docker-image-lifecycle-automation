# Product Terminology

Use the terms in this guide consistently in documentation, pull requests,
workflow summaries, and user-facing messages.

| Term | Meaning | Avoid |
|---|---|---|
| **Upstream image** | An image referenced by an adopting repository's Dockerfile | Base image, when the source need not be a Docker base |
| **Image drift** | A digest change behind a tag, including a same-tag rebuild | Tag update |
| **Update evidence** | The digest, tag, manifest type, platform, and decision details recorded for review | Update details |
| **Upstream Image Monitor** | The lifecycle stage that detects and proposes upstream changes | Base Image Monitor |
| **Lifecycle policy** | Repository-owned rules for monitoring, verification, releases, and promotion | Automation configuration |
| **Release identifier** | An immutable repository-controlled release label | Release tag strategy |
| **Promotion alias** | An optional mutable convenience tag, such as `latest` or `stable` | Release tag |
| **Publish and verify** | Publishing followed by remote digest confirmation and optional signature verification | Publish |
| **Registry authentication** | Credential or OIDC exchange used to access a registry | Registry login |
| **Adopting repository** | A repository using this platform | Consumer repository |
| **Lifecycle distribution repository** | This repository, which publishes actions and workflows | Platform repository |

## Message hierarchy

1. **Detect real upstream image changes by digest.**
2. **Create reviewable Dockerfile updates.**
3. **Build, verify, sign, release, and publish trusted OCI images.**
4. **Keep approvals, policies, registries, and releases under adopting-repository control.**
