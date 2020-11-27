#!/bin/bash

pushd $(dirname $BASH_SOURCE)

export CK8S_CONFIG_PATH=$(pwd)/aws_glasswall-kubespray-jk
unset CK8S_CLOUD_PROVIDER

export CK8S_PGP_FP=C23FDC9A49016B30199DDC86D1F9F9A9ABE5282B
export CK8S_ENVIRONMENT_NAME=glasswall-kubespray


export GW_ICAP_ALLOWED_DOMAINS=gov.uk.glasswall-ck8s-proxy.com,www.gov.uk.glasswall-ck8s-proxy.com,assets.publishing.service.gov.uk.glasswall-ck8s-proxy.com
export GW_ICAP_ROOT_DOMAIN=glasswall-ck8s-proxy.com
export GW_ICAP_SUBFILTER_ENV=".gov.uk,.gov.uk.glasswall-ck8s-proxy.com  .amazonaws.com,.amazonaws.com.gov.uk.glasswall-ck8s-proxy.com"
export GW_ICAP_ADDITIONAL_HOST_0=www.gov.uk.glasswall-ck8s-proxy.com
export GW_ICAP_ADDITIONAL_HOST_1=assets.publishing.service.gov.uk.glasswall-ck8s-proxy.com
export GW_ICAP_URL=gov.uk.glasswall-ck8s-proxy.com

popd
