#!/usr/bin/env bash
#
# Single source of truth for OCI digest resolution.
# Invoked by both the root Marketplace action (action.yml) and the
# internal composite action (.github/actions/resolve-image-digest).
# Neither wraps the other, so the published action carries no
# dependency on a released tag of this same repository.
#
# Required env: REGISTRY REPOSITORY TAG
# Optional env: REGISTRY_USERNAME REGISTRY_PASSWORD VERIFY_STABILITY

set -euo pipefail

{
  echo "resolved=false"
  echo "digest="
  echo "media_type="
  echo "is_multi_arch=false"
  echo "platforms="
} >> "$GITHUB_OUTPUT"

if [ -z "$TAG" ]; then
  echo "::warning::No tag supplied; cannot resolve a digest."
  exit 0
fi

# Docker Hub's public API host differs from its canonical name.
API_HOST="$REGISTRY"
[ "$REGISTRY" = "docker.io" ] && API_HOST="registry-1.docker.io"

# Fixed, ordered Accept set. Index types first so multi-arch images
# resolve to their index digest (the canonical identity) instead of
# a downgraded single-arch manifest with a different digest.
ACCEPT='application/vnd.oci.image.index.v1+json,application/vnd.docker.distribution.manifest.list.v2+json,application/vnd.oci.image.manifest.v1+json,application/vnd.docker.distribution.manifest.v2+json'

# ---- Discover auth scheme from the registry's own challenge ----
CHALLENGE="$(
  curl -sS -o /dev/null -D - "https://${API_HOST}/v2/" 2>/dev/null \
  | tr -d '\r' \
  | awk 'BEGIN{IGNORECASE=1} /^www-authenticate:/{sub(/^[^:]*:[[:space:]]*/,""); print; exit}'
)" || CHALLENGE=""

AUTH_HEADER=""
case "$CHALLENGE" in
  [Bb]earer*)
    REALM="$(printf '%s' "$CHALLENGE" | sed -nE 's/.*[Rr]ealm="([^"]+)".*/\1/p')"
    SERVICE="$(printf '%s' "$CHALLENGE" | sed -nE 's/.*[Ss]ervice="([^"]+)".*/\1/p')"
    if [ -n "$REALM" ]; then
      TOKEN_URL="${REALM}?scope=repository:${REPOSITORY}:pull"
      [ -n "$SERVICE" ] && TOKEN_URL="${TOKEN_URL}&service=${SERVICE}"
      if [ -n "$REGISTRY_USERNAME" ]; then
        TOKEN_RESPONSE="$(curl -sS --retry 3 --retry-delay 2 --retry-all-errors \
          -u "${REGISTRY_USERNAME}:${REGISTRY_PASSWORD}" "$TOKEN_URL" || true)"
      else
        TOKEN_RESPONSE="$(curl -sS --retry 3 --retry-delay 2 --retry-all-errors "$TOKEN_URL" || true)"
      fi
      TOKEN="$(printf '%s' "$TOKEN_RESPONSE" | jq -r '.token // .access_token // empty' 2>/dev/null || true)"
      if [ -n "$TOKEN" ]; then
        echo "::add-mask::$TOKEN"
        AUTH_HEADER="Authorization: Bearer ${TOKEN}"
      fi
    fi
    ;;
  [Bb]asic*)
    if [ -n "$REGISTRY_USERNAME" ]; then
      BASIC="$(printf '%s:%s' "$REGISTRY_USERNAME" "$REGISTRY_PASSWORD" | base64 -w0)"
      echo "::add-mask::$BASIC"
      AUTH_HEADER="Authorization: Basic ${BASIC}"
    fi
    ;;
  *)
    # No challenge: open registry, or one needing plain basic auth.
    if [ -n "$REGISTRY_USERNAME" ]; then
      BASIC="$(printf '%s:%s' "$REGISTRY_USERNAME" "$REGISTRY_PASSWORD" | base64 -w0)"
      echo "::add-mask::$BASIC"
      AUTH_HEADER="Authorization: Basic ${BASIC}"
    fi
    ;;
esac

MANIFEST_URL="https://${API_HOST}/v2/${REPOSITORY}/manifests/${TAG}"

# Resolve via HEAD (no body transfer, minimal rate-limit cost) and
# read the registry-authoritative Docker-Content-Digest header.
read_digest_headers() {
  if [ -n "$AUTH_HEADER" ]; then
    curl -sS -I --retry 3 --retry-delay 2 --retry-all-errors \
      -H "$AUTH_HEADER" -H "Accept: ${ACCEPT}" "$MANIFEST_URL" 2>/dev/null || true
  else
    curl -sS -I --retry 3 --retry-delay 2 --retry-all-errors \
      -H "Accept: ${ACCEPT}" "$MANIFEST_URL" 2>/dev/null || true
  fi
}

extract_digest() {
  printf '%s' "$1" | tr -d '\r' \
    | awk 'BEGIN{IGNORECASE=1} /^docker-content-digest:/{sub(/^[^:]*:[[:space:]]*/,""); print; exit}'
}

HEADERS="$(read_digest_headers)"
DIGEST="$(extract_digest "$HEADERS")"

# Fallback: some registries omit the header on HEAD. Digest the raw
# manifest bytes directly - never a re-serialised body, since the
# digest is computed over exact bytes.
if [ -z "$DIGEST" ]; then
  if [ -n "$AUTH_HEADER" ]; then
    BODY_DIGEST="$(curl -sS --retry 3 --retry-delay 2 --retry-all-errors \
      -H "$AUTH_HEADER" -H "Accept: ${ACCEPT}" "$MANIFEST_URL" 2>/dev/null | sha256sum | cut -d' ' -f1 || true)"
  else
    BODY_DIGEST="$(curl -sS --retry 3 --retry-delay 2 --retry-all-errors \
      -H "Accept: ${ACCEPT}" "$MANIFEST_URL" 2>/dev/null | sha256sum | cut -d' ' -f1 || true)"
  fi
  [ -n "$BODY_DIGEST" ] && DIGEST="sha256:${BODY_DIGEST}"
fi

if [ -z "$DIGEST" ] || ! printf '%s' "$DIGEST" | grep -qE '^sha[0-9]+:[0-9a-f]+$'; then
  echo "::warning::Could not resolve a digest for ${REGISTRY}/${REPOSITORY}:${TAG}. The tag may not exist, or the registry may require credentials."
  exit 0
fi

# Stability check: a second read must agree, guarding against
# CDN/replica skew being misreported as a real upstream change.
if [ "$VERIFY_STABILITY" = "true" ]; then
  sleep 2
  DIGEST2="$(extract_digest "$(read_digest_headers)")"
  if [ -n "$DIGEST2" ] && [ "$DIGEST2" != "$DIGEST" ]; then
    echo "::warning::Registry returned inconsistent digests for ${REPOSITORY}:${TAG} ($DIGEST vs $DIGEST2). Treating as unstable and skipping this run."
    exit 0
  fi
fi

echo "Resolved ${REGISTRY}/${REPOSITORY}:${TAG} -> ${DIGEST}"

# Fetch the manifest body purely as PR evidence: media type and, for
# multi-arch indexes, the platform list. Never used for the decision.
if [ -n "$AUTH_HEADER" ]; then
  MANIFEST="$(curl -sS -H "$AUTH_HEADER" -H "Accept: ${ACCEPT}" "$MANIFEST_URL" 2>/dev/null || true)"
else
  MANIFEST="$(curl -sS -H "Accept: ${ACCEPT}" "$MANIFEST_URL" 2>/dev/null || true)"
fi

MEDIA_TYPE="$(printf '%s' "$MANIFEST" | jq -r '.mediaType // empty' 2>/dev/null || true)"
PLATFORMS="$(
  printf '%s' "$MANIFEST" \
  | jq -r '[.manifests[]? | select(.platform.os != "unknown") | "\(.platform.os)/\(.platform.architecture)"] | unique | join(",")' 2>/dev/null || true
)"
IS_MULTI_ARCH=false
[ -n "$PLATFORMS" ] && IS_MULTI_ARCH=true

{
  echo "resolved=true"
  echo "digest=$DIGEST"
  echo "media_type=$MEDIA_TYPE"
  echo "is_multi_arch=$IS_MULTI_ARCH"
  echo "platforms=$PLATFORMS"
} >> "$GITHUB_OUTPUT"
