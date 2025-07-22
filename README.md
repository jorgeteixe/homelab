# Homelab

A Docker-based homelab setup with Cloudflare tunnels, Tailscale networking, and various self-hosted services.

## Overview

This homelab configuration uses Docker Compose to orchestrate multiple services including:

- **Cloudflared**: Cloudflare tunnel for public access
- **Tailscale**: Private network for secure internal access
- **Caddy**: Reverse proxy with automatic HTTPS via Cloudflare DNS and Tailscale

## Services

### Web Interface Access

Services are accessible via subdomain routing on `lab.teixe.es`:
- Main dashboard: `lab.teixe.es`
- Individual services: `<service>.lab.teixe.es`

### Useful commands

- Encrypt env file: `sops --encrypt --input-type dotenv .env > .env.enc`

## License

See [LICENSE](LICENSE) file for details.
