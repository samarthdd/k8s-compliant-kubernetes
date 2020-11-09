#!/bin/bash

cd $(dirname "$0")

export CK8S_CONFIG_PATH=$(pwd)/aws_glasswall-test-ck
export CK8S_CODE_PATH=$(pwd)/ck8s-cluster
export CK8S_PGP_FP=65FC8FACF4484F052A84F64F7A02A1A19BBB5AC2

# Disabled for now, breaks cluster
#make -C ck8s-cluster build
#./ck8s_linux_amd64 apply --cluster sc
#./ck8s_linux_amd64 apply --cluster wc

export CK8S_ENVIRONMENT_NAME=glasswall-test-ck
export CK8S_CLOUD_PROVIDER=aws

pushd compliantkubernetes-apps
./bin/ck8s apply sc
./bin/ck8s apply wc

./bin/ck8s test sc
./bin/ck8s test wc
popd
