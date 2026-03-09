#!/usr/bin/env bash
set -euo pipefail

BUILDER="my-builder"
PLATFORMS="linux/amd64,linux/arm64"
REPO="motorcms/motor-headless-php-84"
VERSION="${1:?Usage: $0 <version> [prod|dev] [alpine]}"
TARGET="${2:-all}"
VARIANT="${3:-debian}"

if [[ "$VARIANT" == "alpine" ]]; then
    DOCKERFILE="Dockerfile.alpine"
    REPO="${REPO}-alpine"
else
    DOCKERFILE="Dockerfile"
fi

build() {
    local target="$1" suffix="$2"
    echo "🔨 Building ${target} (${VARIANT}) v${VERSION}..."
    docker buildx build \
        --builder "$BUILDER" \
        --platform "$PLATFORMS" \
        --target "$target" \
        -f "$DOCKERFILE" \
        -t "${REPO}-${suffix}:${VERSION}" \
        --push --no-cache --pull .
}

case "$TARGET" in
    prod) build production prod ;;
    dev)  build dev dev ;;
    all)  build production prod && build dev dev ;;
    *)    echo "❌ Unknown target: $TARGET (use prod, dev, or omit for both)" && exit 1 ;;
esac

echo "✅ Done"
