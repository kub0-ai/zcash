#!/bin/bash
set -e

if [ -n "${UID+x}" ] && [ "${UID}" != "0" ]; then
  usermod -u "$UID" zcash 2>/dev/null || true
fi

if [ -n "${GID+x}" ] && [ "${GID}" != "0" ]; then
  groupmod -g "$GID" zcash 2>/dev/null || true
fi

echo "$0: assuming uid:gid for zcash:zcash of $(id -u zcash):$(id -g zcash)"

if [ "$(echo "$1" | cut -c1)" = "-" ]; then
  echo "$0: assuming arguments for zcashd"
  set -- zcashd "$@"
fi

if [ "$1" = "zcashd" ] || [ "$1" = "zcash-cli" ] || [ "$1" = "zcash-tx" ]; then
  mkdir -p "$ZCASH_DATA"
  chmod 700 "$ZCASH_DATA"
  find "$(getent passwd zcash | cut -d: -f6)" -writable -exec chown zcash:zcash {} + 2>/dev/null || true
  find "$ZCASH_DATA" -writable -exec chown zcash:zcash {} + 2>/dev/null || true
  echo "$0: setting data directory to $ZCASH_DATA"
  set -- "$@" -datadir="$ZCASH_DATA"
fi

if [ "$1" = "zcashd" ] || [ "$1" = "zcash-cli" ] || [ "$1" = "zcash-tx" ]; then
  exec gosu zcash "$@"
fi

exec "$@"
