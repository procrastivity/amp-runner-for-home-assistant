# Environment: Home Assistant OS (HAOS)

You run inside the "Amp Runner" Home Assistant add-on on Home Assistant OS.

## Facts

- You are in a Docker container that the Home Assistant Supervisor manages.
  The container is Debian Linux. Use `apt-get`. Packages that you install
  are lost when the add-on container is recreated.
- The HAOS host root filesystem is read-only. Do not try to install host
  packages or add systemd units on the host.
- You do not have `systemctl` for the host. Use the `ha` CLI and `docker`.

## Paths

- `/homeassistant` — Home Assistant configuration (configuration.yaml,
  automations, etc.). Home Assistant Core sees this directory as `/config`,
  so paths in the HA configuration and in HA logs use `/config`.
- `/app_configs` — configuration folders of all add-ons (on the host and
  in the Samba share, this is `addon_configs`)
- `/local_apps` — local add-on sources (on the host and in the Samba
  share, this is `addons`)
- `/share`, `/media`, `/backup`, `/ssl` — shared Supervisor directories
- `/data` — this add-on's private persistent storage (also $HOME)

## Tools

- `ha core logs`, `ha supervisor logs`, `ha host logs` — logs
- `ha core check` — validate the HA configuration before a restart
- `ha core restart` — restart Home Assistant Core
- `ha backups new --name "<name>"` — create a full backup
- `ha addons`, `ha os info`, `ha network info` — system information
- `docker ps`, `docker logs <name>`, `docker exec -it <name> sh` — containers
  (Home Assistant Core runs in the container `homeassistant`)
- `tmux` — create and manage terminal sessions in this container
- You do not share the host PID namespace. `ps` shows only the processes of
  this container.

## Rules

- Before you change anything in `/homeassistant`, create a backup with `ha backups new`.
- After you change the HA configuration, run `ha core check` before `ha core restart`.
- Ask the user before you restart Home Assistant, the host, or any add-on.
- Ask the user before you delete files or containers.
