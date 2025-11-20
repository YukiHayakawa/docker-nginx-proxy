#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${REPO_ROOT}/.env"
VHOST_DIR="${REPO_ROOT}/nginx/vhost.d"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing .env file at ${ENV_FILE}" >&2
  exit 1
fi

set -o allexport
# shellcheck disable=SC1090
source "${ENV_FILE}"
set +o allexport

if [[ -z "${ACCESS_RESTRICTED_HOSTS:-}" ]]; then
  echo "ACCESS_RESTRICTED_HOSTS is not set in ${ENV_FILE}" >&2
  exit 1
fi

if [[ -z "${ALLOWED_IPS:-}" ]]; then
  echo "ALLOWED_IPS is not set in ${ENV_FILE}" >&2
  exit 1
fi

mkdir -p "${VHOST_DIR}"

normalize_csv() {
  local raw="$1"
  printf '%s\n' "${raw}" | tr ',' '\n' | while IFS= read -r line; do
    line="${line//$'\r'/}"
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "${line}" ]] && continue
    printf '%s\n' "${line}"
  done
}

allowed_ips=()
while IFS= read -r ip; do
  allowed_ips+=("${ip}")
done < <(normalize_csv "${ALLOWED_IPS}")

restricted_hosts=()
while IFS= read -r host; do
  restricted_hosts+=("${host}")
done < <(normalize_csv "${ACCESS_RESTRICTED_HOSTS}")

if [[ ${#allowed_ips[@]} -eq 0 ]]; then
  echo "No ALLOWED_IPS values were parsed from ${ENV_FILE}" >&2
  exit 1
fi

if [[ ${#restricted_hosts[@]} -eq 0 ]]; then
  echo "No ACCESS_RESTRICTED_HOSTS values were parsed from ${ENV_FILE}" >&2
  exit 1
fi

for host in "${restricted_hosts[@]}"; do
  [[ -z "${host}" ]] && continue
  vhost_file="${VHOST_DIR}/${host}"
  {
    for ip in "${allowed_ips[@]}"; do
      [[ -z "${ip}" ]] && continue
      printf 'allow %s;\n' "${ip}"
    done
    printf 'deny all;\n'
  } > "${vhost_file}"
  echo "Wrote ${vhost_file}"
done
