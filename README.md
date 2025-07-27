# Raspberry Pi Homelab

[![ACL Apply](https://github.com/jorgeteixe/homelab/actions/workflows/acl-apply.yml/badge.svg)](https://github.com/jorgeteixe/homelab/actions/workflows/acl-apply.yml)
[![Docker Compose Apply](https://github.com/jorgeteixe/homelab/actions/workflows/docker-apply.yml/badge.svg)](https://github.com/jorgeteixe/homelab/actions/workflows/docker-apply.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

This repository contains the configuration that powers my personal Raspberry Pi homelab. Feel free to read and open issues with suggestions, but note that pull requests are unlikely to be accepted as any change here directly affects my own services.

## Repository layout

- `cloud-init/` – `flash.sh` to create the SD card image and the `user-data`/`network-config` files (encrypted with SOPS).
- `docker/` – compose stack and per-service configuration for Caddy, CoreDNS, Homepage, Calibre and more.
- `tailscale/` – Tailnet ACL policy that gets synced by GitHub Actions.
- `.github/workflows/` – automation that applies the ACL and triggers compose updates.
- `Justfile` – helper tasks to encrypt secrets, flash the SD card and start containers.

## Usage

Most tasks are automated using [`just`](https://github.com/casey/just). Common commands:

```bash
just flash /dev/sdX   # Download Ubuntu, write the image and copy cloud-init files
just encrypt          # Encrypt user-data and docker .env using sops
just decrypt          # Decrypt the encrypted files
just docker-up        # Pull images and start the compose stack
```

## Contributing

Suggestions are welcome via issues, but contributions will probably not be accepted because this project controls my personal infrastructure.

## License

This project is available under the [MIT license](LICENSE).
