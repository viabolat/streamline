#!/usr/bin/env bash
set -eu

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
if [[ -z ${AWS_REGION} ]]; then
    echo 'Please set variable AWS_REGION'
    exit 1
fi
if [[ -z ${AWS_REGION+x} ]]; then
    echo 'Please set variable AWS_REGION'
    exit 1
fi

account_id=$(aws sts get-caller-identity --output text --query 'Account')
case "${account_id}" in
066991206117)
    ACCOUNT="conveh"
    STAGE="int"
    ;;
482694160481)
    ACCOUNT="conveh"
    STAGE="prod"
    ;;
*) echo "Account id ${account_id} unknown"
    exit 1
    ;;
esac

case "$1" in
plan) MODE="plan" PLAN="${2:-tfplan}"
  ;;
apply-plan) MODE="apply-plan" PLAN="${2:-tfplan}"
  ;;
*) MODE="apply"
  ;;
esac

echo "ACCOUNT ${ACCOUNT} STAGE ${STAGE}, REGION ${AWS_REGION}"
export AWS_REGION=${AWS_REGION}
pushd "$DIR/accounts/${ACCOUNT}"|| exit

VARIABLE_BASE_DIR="../../vars/${ACCOUNT}"
VARIABLE_DIR="${VARIABLE_BASE_DIR}/${AWS_REGION}/${STAGE}"
BACKEND_CONFIG_FILE="backend-config.hcl"

case "$MODE" in
plan)
  terraform init -reconfigure -backend-config="${VARIABLE_DIR}/${BACKEND_CONFIG_FILE}"
  terraform plan -var-file="${VARIABLE_BASE_DIR}/${STAGE}.tfvars" -var-file="${VARIABLE_DIR}/variables.tfvars" -out="$PLAN"
  ;;
apply-plan)
  terraform apply -auto-approve "$PLAN"
  ;;
apply)
  terraform init -reconfigure -backend-config="${VARIABLE_DIR}/${BACKEND_CONFIG_FILE}"
  terraform apply -var-file="${VARIABLE_BASE_DIR}/${STAGE}.tfvars" -var-file="${VARIABLE_DIR}/variables.tfvars"
  ;;
esac

popd || exit