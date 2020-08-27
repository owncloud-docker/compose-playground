#!/usr/bin/env bash
set -x

occ app:enable encryption
occ encryption:enable
occ encryption:select-encryption-type masterkey -y

true