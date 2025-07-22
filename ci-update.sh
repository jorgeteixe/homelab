#!/bin/bash
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"
git pull
sops --decrypt --input-type dotenv --output-type dotenv .env.enc > .env
docker compose pull
docker compose up -d --remove-orphans
docker image prune -f
