#!/bin/bash
git pull
sops --decrypt --input-type dotenv --output-type dotenv .env.enc > .env
docker compose pull
docker compose up -d --remove-orphans
