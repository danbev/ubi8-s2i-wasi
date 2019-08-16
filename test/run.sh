#!/bin/bash
#
# The 'run' performs a simple test that verifies that STI image.
# The main focus here is to excersise the STI scripts.
#
# IMAGE_NAME specifies a name of the candidate image used for testing.
# The image has to be available before this script is executed.
#
BUILDER=${BUILDER}

APP_IMAGE="$(echo ${BUILDER} | cut -f 1 -d':')-testapp"

test_dir=`dirname ${BASH_SOURCE[0]}`
image_dir="${test_dir}/.."
cid_file=`date +%s`$$.cid

# Since we built the candidate image locally, we don't want S2I attempt to pull
# it from Docker hub
s2i_args="--pull-policy never "

# TODO: This should be part of the image metadata
test_port=8080

image_exists() {
  docker inspect $1 &>/dev/null
}

container_exists() {
  image_exists $(cat $cid_file)
}

container_ip() {
  docker inspect --format="{{ .NetworkSettings.IPAddress }}" $(cat $cid_file)
}

container_logs() {
  docker logs $(cat $cid_file)
}

run_s2i_build() {
  echo "Running s2i build ${s2i_args} ${test_dir}/test-app ${BUILDER} ${APP_IMAGE}"
  s2i build ${s2i_args} --exclude "(^|/)node_modules(/|$)" ${test_dir}/test-app ${BUILDER} ${APP_IMAGE}
}

prepare() {
  if ! image_exists ${BUILDER}; then
    echo "ERROR: The image ${BUILDER} must exist before this script is executed."
    exit 1
  fi
}

run_test_application() {
  echo "Starting test application ${APP_IMAGE}..."
  docker run --cidfile=${cid_file} -p ${test_port}:${test_port} $1 ${APP_IMAGE}
}

cleanup() {
  if [ -f $cid_file ]; then
    if container_exists; then
      cid=$(cat $cid_file)
      docker stop $cid
      exit_code=`docker inspect --format="{{ .State.ExitCode }}" $cid`
      echo "Container exit code = $exit_code"
      # Only check the exist status for non DEV_MODE
      if [ "$1" == "false" ] &&  [ "$exit_code" != "222" ] ; then
        echo "ERROR: The exist status should have been 222."
        exit 1
      fi
    fi
  fi
  cids=`ls -1 *.cid 2>/dev/null | wc -l`
  if [ $cids != 0 ]
  then
    rm *.cid
  fi
}

check_result() {
  local result="$1"
  if [[ "$result" != "0" ]]; then
    echo "STI image '${BUILDER}' test FAILED (exit code: ${result})"
    cleanup
    exit $result
  fi
}

wait_for_cid() {
  local max_attempts=10
  local sleep_time=1
  local attempt=1
  local result=1
  while [ $attempt -le $max_attempts ]; do
    [ -f $cid_file ] && [ -s $cid_file ] && break
    echo "Waiting for container start..."
    attempt=$(( $attempt + 1 ))
    sleep $sleep_time
  done
}

test_image_usage_label() {
  local expected="s2i build . nodeshift/ubi8-s2i-wasi myapp"
  local prod_expected="s2i build . rhoar-nodejs/ubi8-s2i-wasi myapp"
  local failed=false
  echo "Checking image usage label ..."
  out=$(docker inspect --format '{{ index .Config.Labels "usage" }}' $BUILDER)

  if ! echo "${out}" | grep -q "${expected}"; then
    if echo "${out}" | grep -q "${prod_expected}"; then
      return 0;
    else
      echo "ERROR[docker inspect --format \"{{ index .Config.Labels \"usage\" }}\"] Expected '${prod_expected}', got '${out}'"
      return 1
    fi
    echo "ERROR[docker inspect --format \"{{ index .Config.Labels \"usage\" }}\"] Expected '${expected}', got '${out}'"
    return 1
  fi
}

prepare
test_image_usage_label
check_result $?

prepare
run_s2i_build
check_result $?

run_test_application
check_result $?

cleanup 
if image_exists ${APP_IMAGE}; then
  docker rmi -f ${APP_IMAGE}
  # echo "<><><><><><><><><><><> NOT CLEANING UP åå<><><><><><><><><><><>"
fi

echo "Success!"
