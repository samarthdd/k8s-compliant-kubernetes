#!/bin/bash

pushd $(dirname $BASH_SOURCE)

export CK8S_CONFIG_PATH=$(pwd)/aws_glasswall-test-ck
export CK8S_CODE_PATH=$(pwd)/ck8s-cluster
export CK8S_PGP_FP=65FC8FACF4484F052A84F64F7A02A1A19BBB5AC2

export GW_ICAP_ALLOWED_DOMAINS=gov.uk.ck.glasswall-ck8s-proxy.com,www.gov.uk.ck.glasswall-ck8s-proxy.com,assets.publishing.service.gov.uk.ck.glasswall-ck8s-proxy.com
export GW_ICAP_ROOT_DOMAIN=ck.glasswall-ck8s-proxy.com
export GW_ICAP_SUBFILTER_ENV=".gov.uk,.gov.uk.ck.glasswall-ck8s-proxy.com  .amazonaws.com,.amazonaws.com.gov.uk.ck.glasswall-ck8s-proxy.com"
export GW_ICAP_ADDITIONAL_HOST_0=www.gov.uk.ck.glasswall-ck8s-proxy.com
export GW_ICAP_ADDITIONAL_HOST_1=assets.publishing.service.gov.uk.ck.glasswall-ck8s-proxy.com
export GW_ICAP_URL=gov.uk.ck.glasswall-ck8s-proxy.com

popd
