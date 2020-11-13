#!/bin/bash

pushd $(dirname $BASH_SOURCE)

export CK8S_CONFIG_PATH=$(pwd)/aws_glasswall-test-ck
export CK8S_CODE_PATH=$(pwd)/ck8s-cluster
export CK8S_PGP_FP=65FC8FACF4484F052A84F64F7A02A1A19BBB5AC2

popd
