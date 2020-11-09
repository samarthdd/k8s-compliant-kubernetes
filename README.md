# gp-gov-uk-website

## Deployment instruction

1. Deploy ck8s-cluster - follow the instructions in [README file](ck8s-cluster/README.md)

    Currently, Glasswall ICAP components require running as root, so some of the checks in the restricted PSP has to be relaxed.

2. Deploy compliantkubernetes-apps - follow the instructions in [README file](compliantkubernetes-apps/README.md)

    As part of the Compliant Kubernetes Apps deployment also Glasswall ICAP components defined in `helmfile/02-glasswall-icap.yaml` are installed.
    If you need to reapply it again use:

        ./bin/ck8s ops helmfile wc -f helmfile/02-glasswall-icap.yaml apply

    The Glasswall ICAP deployment is not fully automated yet, so you need to perform some manual actions listed below.

3. Create PVs

        ./bin/ck8s ops kubectl wc apply -f ../local-storage-pv.yaml

4. Find the IP address of icap-adaptaion service:

        ./bin/ck8s ops kubectl wc -n icap-adaptation get svc | grep icap-service

5. Replace env var with the IP value
    The server url should be : icap://<ip_recorded above>:1344/gw_rebuild

        ./bin/ck8s ops kubectl wc -n icap-adaptation edit deployment/glasswall-icap-nginx
        ./bin/ck8s ops kubectl wc -n icap-adaptation edit deployment/glasswall-icap-squid

## Delete ICAP deployment

        ./bin/ck8s ops helmfile wc -f helmfile/02-glasswall-icap.yaml destroy
        ./bin/ck8s ops kubectl wc delete pv local-pv-1 local-pv-2
