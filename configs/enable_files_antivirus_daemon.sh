#!/usr/bin/env bash
set -xe

wait-for-it -t 180 clamav:3310

occ market:install files_antivirus
occ app:enable files_antivirus
occ config:app:set files_antivirus av_mode --value="daemon"
occ config:app:set files_antivirus av_host --value="clamav"
occ config:app:set files_antivirus av_port --value="3310"

true
