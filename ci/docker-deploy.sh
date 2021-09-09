#!/bin/bash
#
# quick docker deploy
#
# optional dockerhub login
set -e -o pipefail
export DOCKERHUB_LOGIN="${DOCKERHUB_LOGIN:-}"
export DOCKERHUB_TOKEN="${DOCKERHUB_TOKEN:-}"

export APP_NAME="${APP_NAME:-ghost}"
export APP_BRANCH="${APP_BRANCH:-master}"
export APP_URL="https://github.com/datalab-mi/${APP_NAME}/archive/refs/heads/${APP_BRANCH}.tar.gz"

export USE_CURL=true

# if authenticated repo
if [ -n "${GITHUB_TOKEN}" ] ; then
  curl_args=" -H \"Authorization: token ${GITHUB_TOKEN}\" "
fi

# if APP_ROLE defined use make up-${APP_ROLE}
if [ -n "$APP_ROLE" ] ;then
 app_role="-${APP_ROLE}"
fi

# download install repo
mkdir -p ${APP_NAME}
eval curl -kL -s $curl_args ${APP_URL} | \
   tar -zxvf - --strip-components=1 -C ${APP_NAME}
# install app (role)
( cd ${APP_NAME}
  if [ -n "$DOCKERHUB_TOKEN" -a -n "$DOCKERHUB_LOGIN" ] ;then  echo $DOCKERHUB_TOKEN | docker login --username $DOCKERHUB_LOGIN --password-stdin ; fi

  make install-rclone
  make up$app_role
  make enable-backup-cron

  if [ -n "$DOCKERHUB_TOKEN" -a -n "$DOCKERHUB_LOGIN" ] ; then docker logout ; fi
)
exit $?
