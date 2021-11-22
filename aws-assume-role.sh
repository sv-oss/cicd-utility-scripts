#!/bin/bash
set -auo pipefail


# Assume the IAM role $1, for duration $3, and allocate a session name derived from $2.
# output: AccessKeyId,SecretAccessKey,SessionToken in tab-separated format
assume_role_credentials() {
  local role="$1"
  local sessionName="$2"
  local duration="$3"
  aws sts assume-role \
    --role-arn "$role" \
    --role-session-name "$sessionName" \
    --duration-seconds "$duration" \
    --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
    --output text
}

# Convert tab-separated credentials to shell export statements
credentials_to_shell_exports() {
  IFS=$'\t' read -r -a KST
  echo "export AWS_ACCESS_KEY_ID='${KST[0]}'"
  echo "export AWS_SECRET_ACCESS_KEY='${KST[1]}'"
  echo "export AWS_SESSION_TOKEN='${KST[2]}'"
}


assume-role() {
  local role="$1"
  local duration="${2:-3600}"
  local name="${3:-${BUILDKITE_BUILD_NUMBER:-$$}}"
  assume_role_credentials "$role" "$name" "$duration" | credentials_to_shell_exports
}