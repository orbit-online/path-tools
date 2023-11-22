#!/usr/bin/env bash
set -eo pipefail; shopt -s inherit_errexit
source "$(upkg root "${BASH_SOURCE[0]}")/path-tools.sh"
path_validate "$@"
