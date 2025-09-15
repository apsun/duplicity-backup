#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

if [ "${EUID}" -ne 0 ] || [ -z "${SUDO_USER:-}" ]; then
    echo >&2 "you must run this script with sudo"
    exit 1
fi

if [ "$#" -gt 1 ]; then
    echo >&2 "usage: $0 [profile]"
    exit 1
fi

install -Dm755 duplicity-backup /usr/local/bin/
install -Dm644 duplicity-backup@.service /etc/systemd/system/
install -Dm644 duplicity-backup@.timer /etc/systemd/system/
install -Dm644 duplicity-backup-watchdog@.service /etc/systemd/user/
install -Dm644 duplicity-backup-watchdog@.timer /etc/systemd/user/
systemctl daemon-reload
echo "installed duplicity-backup binary and systemd units"

if [ "$#" -eq 1 ]; then
    profile="$1"
    profile_dir="/etc/duplicity/${profile}"

    if [ -d "${profile_dir}" ]; then
        echo >&2 "${profile_dir} already exists, preserving existing configuration!"
        echo >&2 "hint: delete ${profile_dir} and re-run this script to replace configuration"
    else
        if ! [ -f "conf.${profile}.example" ]; then
            echo >&2 "create and edit conf.${profile}.example first"
            exit 1
        fi

        install -m700 -d "${profile_dir}"
        install -Dm600 "conf.${profile}.example" "${profile_dir}/conf"
        install -Dm600 <(env -i "USER=${SUDO_USER}" envsubst < include.example) "${profile_dir}/include"
        [ -f ssh_id.example ] && install -Dm600 ssh_id.example "${profile_dir}/ssh_id"
        echo "installed configuration files to ${profile_dir}"
    fi

    systemctl enable --now "duplicity-backup@${profile}.timer"
    echo "enabled duplicity-backup@${profile}.timer"

    if command -v notify-send >/dev/null; then
        systemctl --user --machine "${SUDO_USER}@.host" enable --now "duplicity-backup-watchdog@${profile}.timer"
        echo "enabled duplicity-backup-watchdog@${profile}.timer"
    else
        systemctl --user --machine "${SUDO_USER}@.host" disable --now "duplicity-backup-watchdog@${profile}.timer"
        echo >&2 "warning: notify-send not installed, you will not receive notifications on backup failure"
        echo "disabled duplicity-backup-watchdog@${profile}.timer"
    fi
fi
