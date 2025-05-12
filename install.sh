#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

if [ "$#" -ne 1 ]; then
    echo >&2 "usage: $0 <profile>"
    exit 1
fi

profile="$1"
profile_dir="/etc/duplicity/${profile}"

if ! [ -f "conf.${profile}.example" ]; then
    echo >&2 "create and edit conf.${profile}.example first"
    exit 1
fi

if [ "${EUID}" -ne 0 ]; then
    echo >&2 "you must run this script as root"
    exit 1
fi

install -m700 -d "${profile_dir}"
install -Dm600 "conf.${profile}.example" "${profile_dir}/conf"
install -Dm600 include.example "${profile_dir}/include"
[ -f ssh_id.example ] && install -Dm600 ssh_id.example "${profile_dir}/ssh_id"
install -Dm644 duplicity-backup@.service /etc/systemd/system/
install -Dm644 duplicity-backup@.timer /etc/systemd/system/
install -Dm755 duplicity-backup /usr/local/bin/
systemctl enable --now "duplicity-backup@${profile}.timer"
