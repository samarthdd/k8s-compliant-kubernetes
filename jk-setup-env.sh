#!/bin/bash

pushd $(dirname $BASH_SOURCE)

export CK8S_CONFIG_PATH=$(pwd)/aws_glasswall-test-jk
export CK8S_CODE_PATH=$(pwd)/ck8s-cluster
export CK8S_PGP_FP=C23FDC9A49016B30199DDC86D1F9F9A9ABE5282B
export CK8S_ENVIRONMENT_NAME=glasswall-test
export CK8S_CLOUD_PROVIDER=aws

popd
