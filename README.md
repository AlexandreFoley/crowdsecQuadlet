# Crowdsec Quadlet Container Setup

This guide shows how to configure and deploy Crowdsec using a Podman quadlet on a systemd-based Linux host.

## Basic Setup

Prerequisites:
- Podman and systemd-quadlet installed.

Quadlet files:
- Located in the `quadlet/` directory in this repo.

Configure `crowdsec.container` (`quadlet/crowdsec.container`):
- **DISABLE_LOCAL_API** (default `true`): set to `false` to enable the built-in local API.
- **LOCAL_API_URL** (default `http://127.0.0.1:8080`): remote API endpoint when local disabled.
- **AGENT_USERNAME**: optional for auto-registration; required if using username/password flow.

Volumes (under `[Container]`):
- `crowdsec-db:/var/lib/crowdsec/data` (database storage)
- `./crowdsec/acquis.yaml:/etc/crowdsec/acquis.yaml`
- `/var/log/caddy:/var/log/caddy:ro` (Caddy logs)
- Add additional log mounts as needed.
    - update acquis.yaml 

**COLLECTIONS**: space-separated list of parser collections (e.g. `crowdsecurity/caddy crowdsecurity/http-cve`), you might want more depending on the services behind caddy.


#### Podman Secrets (choose one registration flow)

If The instance is in client mode ( the local api is disabled), choose one of the two registration flow, make sure the other one is removed from the container file. If the local api is enabled, then you must remove both of the registration flow.

Reference: [Crowdsec Machine Registration](https://docs.crowdsec.net/u/user_guides/machines_mgmt#machine-register)

#### 1. Auto-registration token
Retrieve the token on the Crowdsec host from `/etc/crowdsec/config.yaml` under `api.client.registration_token`. Ensure your client IP is allowed by `api.server.auto_registration.allowed_ranges`.
```bash
echo "-n $AUTO_TOKEN" | podman secret create agent_auto_registration_token -
```

#### 2. Username/password flow
##### a) Generate credentials on the Crowdsec host
```bash
cscli machines add "<AGENT_USERNAME>" --password -o json \
  | jq -r .password > agent_password.txt
```
##### b) Create the secret on your container host
```bash
podman secret create agent_password agent_password.txt
```


## Install quadlet

```bash
mkdir -p ~/.config/containers/systemd
cp quadlet/* ~/.config/containers/systemd/
systemctl --user daemon-reload  # reload systemd units after installing quadlet files
systemctl enable --user --now crowdsec.container
```

Enable and start:
```bash
# User session
systemctl --user enable --now crowdsec.container
# Or system-wide
sudo cp -r quadlet/* /etc/containers/systemd/
sudo systemctl daemon-reload  # reload systemd units after installing quadlet files
sudo systemctl enable --now crowdsec.container
```

## Advanced Configuration

- **GitHub Action**: automatically rebuilds the Dockerfile and pushes images to GHCR on changes.
- **Custom Images**: fork the repo, edit the Dockerfile or `docker_start.sh`, then push to trigger your own builds. If you build your own image, update the `Image=` line in `quadlet/crowdsec.container` to point to your registry (e.g. `ghcr.io/<your-user>/<your-repo>:latest`).
- **Additional Tweaks**: override other environment variables or startup logic by editing `docker_start.sh` as needed.

