# gp-gov-uk-website

## Deployment instruction

1. Deploy ck8s-cluster - follow the instructions in [README file](ck8s-cluster/README.md)

    Currently, Glasswall ICAP components require running as root, so some of the checks in the restricted PSP has to be relaxed.

2. Deploy compliantkubernetes-apps - follow the instructions in [README file](compliantkubernetes-apps/README.md)

The Glasswall ICAP deployment is not fully automated yet, so you need to perform some manual actions listed below.

3. Create PVs

        cd compliantkubernetes-apps
        ./bin/ck8s ops kubectl wc apply -f ../local-storage-pv.yaml

4. Create secret

        ./bin/ck8s ops kubectl wc -n icap-adaptation create secret  generic transactionstoresecret \
        --from-literal=accountName=user \
        --from-literal=accountKey='key'

5. Deploy Glasswall ICAP components:

        ./bin/ck8s ops helmfile wc -f ../wip-helmfile-glasswall-icap.yaml apply

6. Find the IP address of icap-adaptaion service:

        ./bin/ck8s ops kubectl wc -n icap-adaptation get svc | grep icap-service

7. Replace env var with the IP value
    The server url should be : icap://<ip_recorded above>:1344/gw_rebuild

        ./bin/ck8s ops kubectl wc -n icap-adaptation edit deployment/glasswall-icap-nginx
        ./bin/ck8s ops kubectl wc -n icap-adaptation edit deployment/glasswall-icap-squid

## Running ICAP

1. Add the following record in `/etc/hosts` file:

        127.0.0.1       gov.uk.glasswall-ck8s-proxy.com www.gov.uk.glasswall-ck8s-proxy.com assets.publishing.service.gov.uk.glasswall-ck8s-proxy.com

2. Forward `4443` port to the `icap-adaptation` service:

        ./bin/ck8s ops kubectl wc -n icap-adaptation port-forward svc/glasswall-icap-reverse-proxy-nginx 4443:443

3. Open a link to a selected resource in an internet browser, remember to use appropiate port, for example: https://www.gov.uk.glasswall-ck8s-proxy.com:4443/guidance/social-care-common-inspection-framework-sccif-voluntary-adoption-agencies/download-pdf-version

    That should spawn a new pod in `icap-adaptation` namespace.

## Delete ICAP deployment

        ./bin/ck8s ops helmfile wc -f helmfile/02-glasswall-icap.yaml destroy
        ./bin/ck8s ops kubectl wc delete pv local-pv-1 local-pv-2

To force delete objects you can use:

        ./bin/ck8s ops kubectl wc -n icap-adaptation delete all --all
        ./bin/ck8s ops kubectl wc -n icap-adaptation delete pvc --all
