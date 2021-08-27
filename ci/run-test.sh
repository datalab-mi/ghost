#!/bin/bash
set -e -o pipefail

#
# test http app
#
function test_app {
  echo "# Test ${1} up"
  set +e
  ret=0
  timeout=120;
  test_result=1
  until [ "$timeout" -le 0 -o "$test_result" -eq "0" ] ; do
      curl -s --fail --retry-max-time 120 --retry-delay 1  --retry 1  http://localhost:80
      test_result=$?
      echo "Wait $timeout seconds: APP coming up ($test_result)";
      (( timeout-- ))
      sleep 1
  done
  if [ "$test_result" -gt "0" ] ; then
       ret=$test_result
       echo "ERROR: APP down"
       return $ret
  fi

  set -e
  return $ret
}

APP_VERSION=$(ci/version.sh)
# Build all services
echo "# up docker $APP_VERSION"

# Up all services
make up

# Simple test app
test_app

# Down all
make down
