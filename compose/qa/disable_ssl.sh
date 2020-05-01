#!/usr/bin/env bash
echo "disabling SSL for remote fed tests"
a2dismod ssl
service apache2 restart
