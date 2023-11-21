#!/usr/bin/env bash
# shellcheck source-path=.
set -eo pipefail; shopt -s inherit_errexit
source "$(upkg root "${BASH_SOURCE[0]}")/path-tools.sh"
path_remove "$@"
