# gp-gov-uk-website

## Deployment instructions

### Create infrastructure

1. Source your environment file

        source jk-setup-env.sh

2. Initialize kubespray environment:

        cd experiment-ck8s-metal
        ./bin/ck8s-kubespray init sc default ~/.ssh/id_rsa.pub
        ./bin/ck8s-kubespray init wc default ~/.ssh/id_rsa.pub

3. Move to the terraform tfe directory

        cd ../ck8s-cluster/terraform/tfe

4. Export TF variables

        export TF_DATA_DIR=${CK8S_CONFIG_PATH}/.state/.terraform-tfe
        export TF_STATE=${CK8S_CONFIG_PATH}/.state/terraform-tfe.tfstate
        export TF_WORKSPACE=ck8s-aws-glasswall-kubespray-jk

5. Create terraform workspace

        terraform init
        terraform apply -var organization=elastisys -var workspace_name=$TF_WORKSPACE

6. Create ck8s service cluster in AWS

        cd ../aws/

        export TF_DATA_DIR=${CK8S_CONFIG_PATH}/.state/.terraform
        export TF_VAR_aws_access_key=YOUR_ACCESS_KEY
        export TF_VAR_aws_secret_key=YOUR_SECRET_KEY
        export TF_VAR_dns_access_key=YOUR_ACCESS_KEY
        export TF_VAR_dns_secret_key=YOUR_SECRET_KEY
        export TF_VAR_ssh_pub_key_sc=~/.ssh/id_rsa.pub
        export TF_VAR_ssh_pub_key_wc=
        export TF_WORKSPACE=glasswall-dev

        terraform init -backend-config ${CK8S_CONFIG_PATH}/backend_config.hcl

        terraform apply -var-file ${CK8S_CONFIG_PATH}/tfvars.json -target module.service_cluster

7. Create ck8s workload cluster in AWS

        export TF_VAR_ssh_pub_key_sc=
        export TF_VAR_ssh_pub_key_wc=~/.ssh/id_rsa.pub

        terraform init -backend-config ${CK8S_CONFIG_PATH}/backend_config.hcl

        terraform apply -var-file ${CK8S_CONFIG_PATH}/tfvars.json -target module.workload_cluster

8. Update `inventory.ini` files in `sc-config` and `wc-config` directories by setting `ansible_host` value to Public IP of respective machine.

### Install Kubernetes

Run in `gp-gov-uk-website/experiment-ck8s-metal`

1. Prepare the environment:

        sudo apt-get install python3-venv
        python3 -m venv venv
        source venv/bin/activate

2. Set the value of `supplementary_addresses_in_ssl_keys` field in `*c-config/group_vars/k8s-cluster.yaml` to the Public IP of respective master nodes (workload and service clusters).

3. Deploy Service Cluster:

        ./bin/ck8s-kubespray apply sc

4. Deploy Workload Cluster:

        ./bin/ck8s-kubespray apply wc

5. Exit python virtual environment

        deactivate

### Install Compliant Kubernetes

Follow the instructions in [README file](compliantkubernetes-apps/README.md)

export CK8S_CLOUD_PROVIDER=aws
export CK8S_FLAVOR=dev
export CK8S_CONFIG_PATH=~/workspace/glasswall/gp-gov-uk-website/aws_glasswall-kubespray-jk

edit kube_config_sc.yaml and kube_config_wc.yaml
set clusters.cluster.server to Public IPs

### Glasswall ICAP

Also, Glasswall ICAP components require running as root, so some of the checks in the restricted PSP has to be relaxed.

1. Relax PodSecurityPolicy:

        cd compliantkubernetes-apps
        ./bin/ck8s ops kubectl wc apply -f ../default-restricted-psp.yaml

2. Deploy Glasswall ICAP components:

        ./bin/ck8s ops helmfile wc -f ../wip-helmfile-glasswall-icap.yaml apply

## Delete ICAP deployment

        ./bin/ck8s ops helmfile wc -f ../wip-helmfile-glasswall-icap.yaml destroy

To force delete objects you can use:

        ./bin/ck8s ops kubectl wc -n icap-adaptation delete all --all
        ./bin/ck8s ops kubectl wc -n icap-adaptation delete pvc --all

## Expose ICAP service

Create LoadBalancer type of service to expose `icap-service`:

        ./bin/ck8s ops kubectl wc expose deployment mvp-icap-service --port=1344 --target-port=1344 --type=LoadBalancer -n icap-adaptation

Create a CNAME record in AWS Hosted Zones to direct trafic to the created AWS Network Load Balancer.

## Testing ICAP service

To test the ICAP service run the following command:

        c-icap-client -f /home/jakub/Downloads/FIVB_VB_Scoresheet_2013_updated2.pdf -i icap.glasswall-ck8s-proxy.com -p 1344 -s gw_rebuild -o ./rebuilt.pdf -v
