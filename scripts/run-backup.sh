#!/bin/bash
#
# run-backup
#   script executed via crontab (cf crontab.cfg)
#
set -e -o pipefail

# Source all configuration variables
libdir=/home/$USER
[ -f ${libdir}/local.cfg ] && source ${libdir}/local.cfg
[ -f ${libdir}/config.cfg ] && source ${libdir}/config.cfg
[ -f ${libdir}/app.cfg ] && source ${libdir}/app.cfg

export no_proxy=$no_proxy
export http_proxy=$internal_http_proxy
export https_proxy=$internal_http_proxy

# Run backup
make -C /home/$USER/ghost backup
