# gp-gov-uk-website

## Build instructions

1. Build `reverse-proxy-nginx` Docker image and push it to the Elastisys repository

       docker build k8-reverse-proxy/stable-src/nginx -t elastisys/reverse-proxy-nginx:0.0.1
       docker push elastisys/reverse-proxy-nginx:0.0.1

2. Build `reverse-proxy-squid` Docker image and push it to the Elastisys repository

       docker build k8-reverse-proxy/stable-src/squid/ -t elastisys/reverse-proxy-squid:0.0.1
       docker push elastisys/reverse-proxy-squid:0.0.1

3. Build `reverse-proxy-c-icap` Docker image and push it to the Elastisys repository

        docker build k8-reverse-proxy/stable-src/c-icap -t elastisys/reverse-proxy-c-icap:0.0.1
        docker push elastisys/reverse-proxy-c-icap:0.0.1

4. Build `icap-request-processing` Docker image and push it to the Elastisys repository

        docker build icap-request-processing -t elastisys/icap-request-processing:test
        docker push elastisys/icap-request-processing:test

## Deployment instructions

1. Deploy ck8s-cluster - follow the instructions in [README file](ck8s-cluster/README.md)

2. Deploy compliantkubernetes-apps - follow the instructions in [README file](compliantkubernetes-apps/README.md)

The Glasswall ICAP deployment is not fully automated yet, so you need to perform some manual actions listed below.
Also, Glasswall ICAP components require running as root, so some of the checks in the restricted PSP has to be relaxed.

3. Relax PodSecurityPolicy:

        cd compliantkubernetes-apps
        ./bin/ck8s ops kubectl wc apply -f ../default-restricted-psp.yaml

4. Create PVs

        ./bin/ck8s ops kubectl wc apply -f ../local-storage-pv.yaml

<!-- 5. Create issuer

        ./bin/ck8s ops kubectl wc apply -f ../icap_cert_issuer.yaml -->

5. Deploy Glasswall ICAP components:

        ./bin/ck8s ops helmfile wc -f ../wip-helmfile-glasswall-icap.yaml apply

## Delete ICAP deployment

        ./bin/ck8s ops helmfile wc -f ../wip-helmfile-glasswall-icap.yaml destroy
        ./bin/ck8s ops kubectl wc delete pv local-pv-1 local-pv-2

To force delete objects you can use:

        ./bin/ck8s ops kubectl wc -n icap-adaptation delete all --all
        ./bin/ck8s ops kubectl wc -n icap-adaptation delete pvc --all

## Expose ICAP service

Create LoadBalancer type of service to expose `icap-service`:

        ./bin/ck8s ops kubectl wc expose deployment mvp-icap-service --port=1344 --target-port=1344 --type=LoadBalancer -n icap-adaptation

Create a CNAME record in AWS Hosted Zones to direct trafic to the created AWS Network Load Balancer.

## Testing ICAP service

To test the ICAP service run the following command:

        c-icap-client -f /home/jakub/Downloads/FIVB_VB_Scoresheet_2013_updated2.pdf -i icap.glasswall-ck8s-proxy.com -p 1344 -s gw_rebuild -o ./rebuilt.pdf
