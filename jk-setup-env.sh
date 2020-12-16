#!/bin/bash

pushd $(dirname $BASH_SOURCE)

export CK8S_CONFIG_PATH=$(pwd)/ovh_glasswall-kubespray-jk
unset CK8S_CLOUD_PROVIDER

export CK8S_PGP_FP=C23FDC9A49016B30199DDC86D1F9F9A9ABE5282B
export CK8S_ENVIRONMENT_NAME=glasswall-ovh-kubespray

export CK8S_CODE_PATH=$(pwd)/ck8s-cluster

export S3_ES_BACKUP_BUCKET_NAME=${CK8S_ENVIRONMENT_NAME}-es-backup
export S3_HARBOR_BUCKET_NAME=${CK8S_ENVIRONMENT_NAME}-harbor
export S3_INFLUX_BUCKET_NAME=${CK8S_ENVIRONMENT_NAME}-influxdb
export S3_SC_FLUENTD_BUCKET_NAME=${CK8S_ENVIRONMENT_NAME}-sc-logs
export S3_VELERO_BUCKET_NAME=${CK8S_ENVIRONMENT_NAME}-velero

source jk-secrets.sh

popd
