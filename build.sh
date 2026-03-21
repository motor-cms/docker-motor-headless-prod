#!/usr/bin/env bash
set -euo pipefail
[[ -f .env ]] && set -a && source .env && set +a

BUILDER="my-builder"
PLATFORMS="linux/amd64,linux/arm64"

IMAGE="${1:?Usage: $0 <php-84|php-85|node> <version> [prod|dev]}"
VERSION="${2:?Usage: $0 <php|php-85|node> <version> [prod|dev]}"
TARGET="${3:-all}"

case "$IMAGE" in
    php-84)
        REPO="motorcms/motor-headless-php-84"
        CONTEXT="php-84"
        BUILD_ARGS=""
        ;;
    php-85)
        REPO="motorcms/motor-headless-php-85"
        CONTEXT="php-85"
        BUILD_ARGS=""
        ;;
    node)
        REPO="motorcms/motor-headless-node-22"
        CONTEXT="node"
        BUILD_ARGS="--build-arg REGISTRY_AUTH_TOKEN=${REGISTRY_AUTH_TOKEN:?Set REGISTRY_AUTH_TOKEN env var}"
        ;;
    *)
        echo "Unknown image: $IMAGE (use php-84, php-85, or node)" && exit 1
        ;;
esac

build() {
    local target="$1" suffix="$2"
    echo "Building ${IMAGE}/${target} v${VERSION}..."
    docker buildx build \
        --builder "$BUILDER" \
        --platform "$PLATFORMS" \
        --target "$target" \
        -f "${CONTEXT}/Dockerfile" \
        $BUILD_ARGS \
        -t "${REPO}-${suffix}:${VERSION}" \
        -t "${REPO}-${suffix}:latest" \
        --push --no-cache --pull "${CONTEXT}"
}

case "$TARGET" in
    prod) build production prod ;;
    dev)  build dev dev ;;
    all)  build production prod && build dev dev ;;
    *)    echo "Unknown target: $TARGET (use prod, dev, or omit for both)" && exit 1 ;;
esac

echo "Done"
