#!/usr/bin/env bash
# Runs the s6 `run` script in the add-on image with a stub `amp` and checks
# the command that it builds for each options file.
#
# bashio reads the add-on options from the Supervisor API
# (GET http://supervisor/addons/self/options/config), not from
# /data/options.json. A BusyBox httpd container on a private Docker network,
# with the network alias `supervisor`, serves each options file in the
# Supervisor response format.
#
# The script runs under bashio directly, not under /command/with-contenv,
# because with-contenv needs the environment that s6 creates at boot.
#
# Build the image first (see amp_runner/DOCS.md), or set IMAGE to another tag.
set -euo pipefail

cd "$(dirname "$0")/.."

IMAGE="${IMAGE:-local/amp_runner:dev}"
MOCK_IMAGE="${MOCK_IMAGE:-busybox:stable}"
SECRET="sk-test-secret-do-not-log"
NETWORK="amp-runner-test-$$"
MOCK="amp-runner-mock-supervisor-$$"
failures=0

www="$(mktemp -d)"
mkdir -p "${www}/addons/self/options"

cleanup() {
    docker rm -f "${MOCK}" > /dev/null 2>&1 || true
    docker network rm "${NETWORK}" > /dev/null 2>&1 || true
    rm -rf "${www}"
}
trap cleanup EXIT

docker network create "${NETWORK}" > /dev/null
docker run -d --rm \
    --name "${MOCK}" \
    --network "${NETWORK}" \
    --network-alias supervisor \
    -v "${www}:/www:ro" \
    "${MOCK_IMAGE}" \
    httpd -f -p 80 -h /www > /dev/null

# run_case OPTIONS EXPECTED_COMMAND [EXPECTED_CWD] [MOUNT_HOMEASSISTANT]
run_case() {
    local options="$1"
    local expected="$2"
    local expected_cwd="${3:-/homeassistant}"
    local mount_homeassistant="${4:-yes}"
    local config_dir output actual actual_cwd
    local mounts=(-v "${PWD}/test/stub-amp.sh:/usr/local/bin/amp:ro")

    jq '{result: "ok", data: .}' "test/${options}" \
        > "${www}/addons/self/options/config"
    chmod a+r "${www}/addons/self/options/config"

    config_dir="$(mktemp -d)"
    if [[ "${mount_homeassistant}" == yes ]]; then
        mounts+=(-v "${config_dir}:/homeassistant")
    fi
    output="$(
        docker run --rm \
            --network "${NETWORK}" \
            --entrypoint /usr/bin/bashio \
            "${mounts[@]}" \
            "${IMAGE}" \
            /etc/s6-overlay/s6-rc.d/amp/run 2>&1
    )" || true
    rmdir "${config_dir}" 2>/dev/null || true

    actual="$(grep -E '^amp ' <<<"${output}" || true)"
    actual_cwd="$(sed -n 's/^cwd //p' <<<"${output}")"
    if [[ "${actual}" == "${expected}" ]]; then
        echo "PASS ${options}: ${actual} (in ${actual_cwd})"
    else
        echo "FAIL ${options}"
        echo "  expected: ${expected}"
        echo "  actual:   ${actual}"
        while IFS= read -r line; do
            echo "  | ${line}"
        done <<<"${output}"
        failures=$((failures + 1))
    fi

    if [[ "${actual_cwd}" != "${expected_cwd}" ]]; then
        echo "FAIL ${options}: Amp started in '${actual_cwd}', expected '${expected_cwd}'"
        failures=$((failures + 1))
    fi

    if grep -q -- "${SECRET}" <<<"${output}"; then
        echo "FAIL ${options}: the output contains the API key"
        failures=$((failures + 1))
    fi

    if jq -e '.api_key // "" | length > 0' "test/${options}" > /dev/null \
        && ! grep -q 'AMP_API_KEY is set' <<<"${output}"; then
        echo "FAIL ${options}: AMP_API_KEY was not exported"
        failures=$((failures + 1))
    fi
}

run_case options.none.json "amp --no-tui"
run_case options.id-only.json "amp --no-tui --runner-id grandmas-garage-server"
run_case options.rct-only.json "amp --no-tui --remote-control-terminal"
run_case options.both.json "amp --no-tui --runner-id grandmas-garage-server --remote-control-terminal"
run_case options.empty-id-with-key.json "amp --no-tui"
run_case options.old-config-dir.json "amp --no-tui" /homeassistant
run_case options.old-config-dir.json "amp --no-tui" /data no

if [[ "${failures}" -gt 0 ]]; then
    echo "${failures} check(s) failed"
    exit 1
fi
echo "All cases passed"
