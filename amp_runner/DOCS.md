# Amp Runner

## Overview

This add-on runs the [Amp](https://ampcode.com) coding agent headless
(`amp --no-tui`) as a supervised service. When Amp exits, the add-on starts
it again. You can then send work to this runner from ampcode.com and let Amp
debug and configure Home Assistant.

## Before you start

- In the **Info** tab, turn off **Protection mode**. The add-on needs this
  for the Docker socket and full hardware access.
- Set the `api_key` option (see below). Without a key or earlier login
  state, Amp cannot log in and does not serve any work.
- In the **Info** tab, turn on **Start on boot** and **Watchdog**.

## Configuration

The options `runner_id` and `api_key` are optional and have no default.
To see them, turn on **Show unused optional configuration options** in the
**Configuration** tab.

The add-on builds the Amp command from the options:

| `runner_id` | `remote_control_terminal` | Command |
|---|---|---|
| unset / empty | `false` | `amp --no-tui` |
| `grandmas-garage-server` | `false` | `amp --no-tui --runner-id grandmas-garage-server` |
| unset / empty | `true` | `amp --no-tui --remote-control-terminal` |
| `grandmas-garage-server` | `true` | `amp --no-tui --runner-id grandmas-garage-server --remote-control-terminal` |

### Option: `runner_id`

Optional. When set, Amp starts with `--runner-id <value>`, which gives the
runner a stable name. Amp requires a valid hostname: letters, digits,
hyphens, and dots. Amp treats the ID as case-insensitive. When empty, Amp
starts without a runner ID.

### Option: `remote_control_terminal`

Default: `false`. When checked, Amp starts with `--remote-control-terminal`.
You can then control the terminals of this runner from ampcode.com.

### Option: `api_key`

Optional. When set, the add-on exports the value as `AMP_API_KEY` for Amp.
Get an access token at <https://ampcode.com/settings/security#access-token>.

Leave the option empty only when Amp already has login state in `/data`.
The add-on has no interactive terminal, so Amp cannot show its login prompt.
Without a key or login state, the log shows
`No API key found. Starting login flow...`, and Amp waits there.
With a key that is not valid, the log shows
`Error: Invalid or missing API key.`, and Amp restarts every few seconds.

### Option: `working_directory`

Default: `/homeassistant`, where the add-on mounts the Home Assistant
configuration directory. Amp starts in this directory. When the directory
does not exist, the add-on logs a warning and uses `/homeassistant`. When
that directory also does not exist, the add-on uses `/data`.

Do not use `/config`. In current Supervisor versions, `/config` is the path
for an add-on's own configuration folder, and this add-on does not map one.


## Persistence

`/data` is the Amp home directory (`HOME=/data`). `/data` survives restarts
and updates, and Home Assistant backups include it. Amp login state and Amp
settings are kept there.

The Amp guidance file is `/data/.config/amp/AGENTS.md`. The add-on installs
a default file on first start. The default file tells Amp how HAOS works.
Edit the file to change what Amp knows about the system. To restore the
default, delete the file and restart the add-on.

## Update Amp

The add-on installs Amp when the image is built. To get a newer Amp, select
**Rebuild** in the add-on **Info** tab.

Amp can also update itself while it runs. To turn this on, set
`"amp.runner.autoUpdate.enabled": true` in `/data/.config/amp/settings.json`.
Such an update stays only until the container is recreated, for example by
a rebuild or an add-on update.

## Logs

The **Log** tab shows the full Amp command and all Amp output. The logged
command never contains the API key.

## Security

> [!WARNING]
> The add-on gives Amp root access, all devices, the Docker socket, and the
> Supervisor admin API. That access is equal to root on the host. Install the
> add-on only on systems that you control.
