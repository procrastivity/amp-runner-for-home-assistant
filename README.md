# Amp Runner for Home Assistant

## What this is

This is a Home Assistant add-on repository with one add-on, **Amp Runner**.
The add-on runs the [Amp](https://ampcode.com) coding agent headless
(`amp --no-tui`) as a supervised service on Home Assistant OS (HAOS).
You can then use Amp to debug and configure Home Assistant remotely.

## Install

1. In Home Assistant, open **Settings → Add-ons → Add-on Store**.
2. Open the top-right menu, select **Repositories**, and add
   `https://github.com/procrastivity/amp-runner-for-home-assistant`.
3. Install **Amp Runner**. The Supervisor builds the image on the device,
   so the first install takes some minutes.

## Local development install

1. Copy the `amp_runner/` directory to `/addons/amp_runner/` on the HAOS
   device (through the Samba or SSH add-on).
2. In the Add-on Store menu, select **Check for updates**.
3. The add-on appears under **Local add-ons**.

## Security warning

> [!WARNING]
> The add-on gives Amp root access, all devices, the Docker socket, and the
> Supervisor admin API. That access is equal to root on the host. Install the
> add-on only on systems that you control.

## Configuration

See [`amp_runner/DOCS.md`](amp_runner/DOCS.md).

## Roadmap

- `icon.png` (128×128) and `logo.png` (250×100).
- Prebuilt multi-arch images on GHCR (`image:` in `config.yaml`, built with
  the `home-assistant/builder` actions in CI).
- An `amp_version` option, or a check for a newer Amp at start.
- An option for extra Amp arguments.
- A small companion custom integration that shows the runner status as an
  entity in Home Assistant.
- A reduced-access profile (no `full_access` or `docker_api`).

## License

[MIT](LICENSE)
