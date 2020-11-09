#!/bin/bash

cd $(dirname "$0")

make -C ck8s-cluster build
./ck8s_linux_amd64 apply --cluster sc
./ck8s_linux_amd64 apply --cluster wc
