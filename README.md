# Motor CMS Docker Base Images

This repository builds and publishes the base Docker images used by [Motor CMS](https://github.com/motor-cms) projects. All images are multi-architecture (linux/amd64 + linux/arm64), Alpine-based, and published to [Docker Hub](https://hub.docker.com/u/motorcms).

## Images

| Image | Base | Variants | Docker Hub |
|-------|------|----------|------------|
| **motor-headless-php-84** | `php:8.4-fpm-alpine` | `prod`, `dev` | `motorcms/motor-headless-php-84` |
| **motor-headless-php-85** | `php:8.5-fpm-alpine` | `prod`, `dev` | `motorcms/motor-headless-php-85` |
| **motor-headless-node-22** | `node:22-alpine` | `prod`, `dev` | `motorcms/motor-headless-node-22` |

Each image has a **production** and **development** variant. Dev variants add debugging tools (Xdebug for PHP, native build tools for Node).

## Repository Structure

```
motor-docker-images/
├── .github/workflows/
│   └── docker-hub.yml        # CI/CD workflow
├── php-84/
│   ├── Dockerfile            # PHP 8.4 multi-stage build
│   ├── entrypoint.sh         # Production entrypoint
│   ├── entrypoint.dev.sh     # Development entrypoint
│   └── xdebug.ini            # Xdebug configuration
├── php-85/
│   ├── Dockerfile            # PHP 8.5 multi-stage build
│   ├── entrypoint.sh
│   ├── entrypoint.dev.sh
│   └── xdebug.ini
├── node/
│   └── Dockerfile            # Node 22 multi-stage build
└── build.sh                  # Local build script
```

## PHP Images (8.4 & 8.5)

### Extensions

Both PHP images ship with the same set of extensions:

`pdo_mysql`, `mysqli`, `mbstring`, `exif`, `pcntl`, `bcmath`, `gd` (freetype + jpeg + webp), `zip`, `soap`, `intl`, `xsl`, `redis`, `imagick`

The dev variant adds **Xdebug** (configured for `host.docker.internal:9003`, trigger-based activation).

### Included Tools

- **Composer** (latest)
- **Supervisor** (process management)
- **dcron** (task scheduling)
- **Image processing**: ImageMagick, ffmpeg, jpegoptim, optipng, pngquant, gifsicle, libavif-apps, libwebp-tools
- **Utilities**: git, curl, wget, jq, zip/unzip

### Entrypoints

The entrypoints are tailored for **Laravel** applications:

**Production** (`entrypoint.sh`):
1. Copies `.env.example` to `.env`
2. Runs `composer install --no-scripts`
3. Starts supervisor and cron daemons
4. Generates Laravel app key, creates storage symlink, runs `php artisan optimize`
5. Starts PHP-FPM

**Development** (`entrypoint.dev.sh`):
- Uses `composer update` with `composer-dev.json` instead
- Clears config, route, and view caches instead of optimizing

Working directory: `/var/www`

## Node Image (22)

### Features

- **pnpm** enabled via corepack
- Preconfigured for **Nitro/Nuxt 3** cluster mode (`NITRO_PRESET=node-cluster`, 10 workers)
- Runs as `www-data` (non-root)
- Exposes port `3000`

The dev variant adds native build tools (`python3`, `make`, `g++`) for compiling native Node modules.

Working directory: `/app`

## GitHub Actions Workflow

The CI/CD pipeline (`.github/workflows/docker-hub.yml`) builds and pushes all images to Docker Hub.

### Triggers

| Trigger | Condition |
|---------|-----------|
| **Schedule** | Every Monday at 3:00 AM UTC |
| **Manual** | Workflow dispatch (select: `php-84`, `php-85`, `node`, or `all`) |
| **Tag push** | Tags matching `*.*.*` (semver) |

### Build Pipeline

Each image follows a two-phase build strategy:

1. **Build phase** — Builds the image on native runners for each architecture in parallel:
   - `ubuntu-latest` for amd64
   - `ubuntu-24.04-arm` for arm64
2. **Merge phase** — Downloads build digests and creates a multi-architecture manifest on Docker Hub

Key resilience features:
- **Retry logic** (up to 3 attempts per build) to handle transient ARM runner issues
- **`fail-fast: false`** so one failing architecture doesn't cancel the other
- **Native ARM runners** instead of QEMU emulation for reliable arm64 builds

### Tagging Strategy

| Tag | Example | When |
|-----|---------|------|
| `latest` | `latest` | Always |
| Semver | `3.0.1`, `3.0`, `3` | Tag push |
| Weekly date | `2026.12` | Scheduled / manual |

## Local Building

```bash
./build.sh <image> <version> [target]
```

**Parameters:**
- `<image>` — `php-84`, `php-85`, or `node`
- `<version>` — Semantic version tag (e.g. `1.0.0`)
- `[target]` — `prod`, `dev`, or `all` (default: `all`)

**Examples:**

```bash
# Build all variants of PHP 8.4
./build.sh php-84 1.0.0

# Build only the dev variant of Node
./build.sh node 1.0.0 dev
```

The script uses Docker Buildx for multi-platform builds (`linux/amd64,linux/arm64`) and pushes directly to Docker Hub. For the Node image, set `REGISTRY_AUTH_TOKEN` in your environment or a `.env` file for npm registry access.

## Requirements

- Docker with Buildx support
- A Docker Hub account with push access to `motorcms/*`
- For Node builds: `REGISTRY_AUTH_TOKEN` for the npm registry
