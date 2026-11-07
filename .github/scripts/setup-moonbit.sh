#!/usr/bin/env bash
set -euo pipefail

# Match the locally validated 2026-11-04 CLI / 2026-11-05 compiler bundle.
readonly MOONBIT_VERSION='0.10.20+65efd5b93'
readonly MOONBIT_VERSION_URL='0.10.20%2B65efd5b93'
readonly MOONBIT_BASE_URL='https://cli.moonbitlang.com'
readonly CORE_SHA256='8ec2a2c01335501d703867bb4eef5f92d3cd7e1ae1ee5f7f14d54d16d2c7c2b5'

# These are the two architectures used by the repository's hosted CI jobs.
case "$(uname -s)-$(uname -m)" in
  Linux-x86_64)
    target='linux-x86_64'
    toolchain_sha256='80d987523308fa490eba9f1baf98df996a5a7891e118357553b7c2608c0597c5'
    ;;
  Darwin-arm64)
    target='darwin-aarch64'
    toolchain_sha256='3ccd56479ba704a779178abe8731490edee9e57b3b90f5cef2252afef4fdf130'
    ;;
  *)
    printf 'Unsupported CI platform: %s\n' "$(uname -s)-$(uname -m)" >&2
    exit 1
    ;;
esac

: "${RUNNER_TEMP:?RUNNER_TEMP must be set}"
: "${GITHUB_ENV:?GITHUB_ENV must be set}"
: "${GITHUB_PATH:?GITHUB_PATH must be set}"

setup_root=$(mktemp -d "${RUNNER_TEMP}/tempo-moonbit.XXXXXX")
readonly setup_root
readonly moon_home="${setup_root}/home"
readonly downloads="${setup_root}/downloads"
mkdir -p "${downloads}" "${moon_home}/lib"

# Only remove downloads created by this invocation, never an existing toolchain.
trap 'rm -rf -- "${downloads}"' EXIT

download() {
  curl --proto '=https' --tlsv1.2 --fail --location --retry 3 \
    --show-error --silent --output "$2" "$1"
}

verify_archive() {
  printf '%s  %s\n' "$1" "$2" | shasum -a 256 --check
}

download \
  "${MOONBIT_BASE_URL}/binaries/${MOONBIT_VERSION_URL}/moonbit-${target}.tar.gz" \
  "${downloads}/toolchain.tar.gz"
download \
  "${MOONBIT_BASE_URL}/cores/core-${MOONBIT_VERSION_URL}.tar.gz" \
  "${downloads}/core.tar.gz"
verify_archive "${toolchain_sha256}" "${downloads}/toolchain.tar.gz"
verify_archive "${CORE_SHA256}" "${downloads}/core.tar.gz"

tar -xzf "${downloads}/toolchain.tar.gz" -C "${moon_home}"
tar -xzf "${downloads}/core.tar.gz" -C "${moon_home}/lib"
ln -s moon "${moon_home}/bin/moonx"
chmod +x "${moon_home}"/bin/* "${moon_home}/bin/internal/tcc"

export MOON_HOME="${moon_home}"
export PATH="${moon_home}/bin:${PATH}"
moon -C "${moon_home}/lib/core" bundle --warn-list -a --all
moon -C "${moon_home}/lib/core" bundle --warn-list -a --target wasm-gc --quiet

printf 'MOON_HOME=%s\n' "${moon_home}" >> "${GITHUB_ENV}"
printf '%s\n' "${moon_home}/bin" >> "${GITHUB_PATH}"
printf 'Installed MoonBit %s in %s\n' "${MOONBIT_VERSION}" "${moon_home}"
moon version --all
