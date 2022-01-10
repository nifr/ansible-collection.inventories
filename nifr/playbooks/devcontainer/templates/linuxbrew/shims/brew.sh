#!/usr/bin/env sh

if ! [ "$(id -u)" = "linuxbrew" ]; then
  exec sudo -u linuxbrew ~linuxbrew/.linuxbrew/bin/brew "$@"
else
  exec ~linuxbrew/.linuxbrew/bin/brew "$@"
fi
