#!/usr/bin/env bash
set -eo pipefail; shopt -s inherit_errexit
source "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/path-tools.sh"
path_remove "$@"
