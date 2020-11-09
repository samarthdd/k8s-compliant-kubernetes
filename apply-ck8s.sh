#!/bin/bash

cd $(dirname "$0")

pushd compliantkubernetes-apps
./bin/ck8s apply sc
./bin/ck8s apply wc

./bin/ck8s test sc
./bin/ck8s test wc
popd
