# Changelog

## 0.1.1

- Fix: the default `working_directory` is now `/homeassistant`, where the
  Home Assistant configuration is mounted. `/config` does not exist in this
  add-on, so the add-on did not start with the default options.
- Fix: when `working_directory` does not exist, the add-on now uses
  `/homeassistant`, then `/data`. Before, it used `/config` and failed.
- The default `AGENTS.md` now gives `/homeassistant` as the path of the
  Home Assistant configuration. The add-on does not replace an existing
  `/data/.config/amp/AGENTS.md`. To get the new default, delete that file
  and restart the add-on.

## 0.1.0

- Initial release: run `amp --no-tui` as a supervised s6 service.
- Options: `runner_id`, `remote_control_terminal`, `api_key`, `working_directory`.
