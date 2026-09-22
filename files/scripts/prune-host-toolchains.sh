#!/usr/bin/env bash
set -euo pipefail

# Wayblue currently carries these as image dependencies. Keep language
# toolchains in Distrobox environments instead of the immutable host.
dnf5 remove -y \
    gcc \
    nodejs22 \
    nodejs22-bin \
    nodejs22-docs \
    nodejs22-full-i18n \
    nodejs22-libs \
    nodejs22-npm \
    nodejs22-npm-bin
