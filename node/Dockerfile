# ── Base ──────────────────────────────────────
FROM node:22-alpine AS base

RUN apk update && apk upgrade --no-cache && \
    delgroup www-data && \
    addgroup -g 33 www-data && \
    adduser -D -u 33 -G www-data -s /bin/sh www-data

WORKDIR /app

# Enable pnpm via corepack
RUN corepack enable

ARG REGISTRY_AUTH_TOKEN
RUN npm config set registry https://npm.registry.zeitraum.io/ && \
    npm set //npm.registry.zeitraum.io/:_authToken=$REGISTRY_AUTH_TOKEN

# ── Production ───────────────────────────────
FROM base AS production

ENV NITRO_PRESET=node-cluster \
    NITRO_CLUSTER_WORKERS=10

RUN chown -R www-data:www-data /app
USER www-data
EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# ── Dev (includes build tools for native modules) ─
FROM base AS dev

RUN apk add --no-cache py3-setuptools python3 make g++

RUN chown -R www-data:www-data /app
USER www-data
EXPOSE 3000

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
