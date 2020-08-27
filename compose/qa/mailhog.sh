#!/usr/bin/env bash
set -x

occ config:system:set mail_domain --value="hog"
occ config:system:set mail_from_address --value="mail"
occ config:system:set mail_smtpmode --value="smtp"
occ config:system:set mail_smtphost --value="mailhog"
occ config:system:set mail_smtpport --value="1025"