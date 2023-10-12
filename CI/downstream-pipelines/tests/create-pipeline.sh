#!/bin/bash

# Strict Mode
set -e pipefail
IFS=$'\n\t'

# Get Script Location
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
readonly SCRIPT_DIR

# GLOBALS
readonly PARALLEL_LIMIT=${PARALLEL_LIMIT:-2}
TEST_IMAGE_TAG=${1:-"master"}

task_needs=()
task_count=1

function createJob() {
  local -r path="$1"
  name="${path#"$SCRIPT_DIR"/}"

  # Get needs task for PARALLEL_LIMIT
  need=""
  if ((task_count >= 3)); then
    index=$((task_count - PARALLEL_LIMIT - 1))
    need="${task_needs[$index]}"
  fi

  if [[ -z "$need" ]]; then
  content="
test:${name}:
  tags:
    - k8s-runner
  stage: test
  image: ubuntu:jammy-20211029
  script:
    - bash ${path}
    - echo ${TEST_IMAGE_TAG}
"
  else
  content="
test:${name}:
  tags:
    - k8s-runner
  stage: test
  image: ubuntu:jammy-20211029
  needs:
    - ${need}
  script:
    - bash ${path}
    - echo ${TEST_IMAGE_TAG}
"
  fi

  # Add the task name to the needs list
  task_name="test:${name}"
  task_needs+=("$task_name")

  # Increment the task count
  ((task_count++))

  # output task
  echo "${content}"
}

function main() {
  for scripts in "${SCRIPT_DIR}"/files/*.sh; do
    # Create a job for the current script
    createJob "${scripts}"
  done
}

main "$@"
