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
        export TF_WORKSPACE=ck8s-ovh-glasswall-kubespray-jk

5. Create terraform workspace

        terraform init
        terraform apply -var organization=elastisys -var workspace_name=$TF_WORKSPACE

6. Create ck8s service cluster in vSphere

        cd ../vsphere/

    Set kubespray configuration following the [official instructions](https://github.com/kubernetes-sigs/kubespray/blob/master/docs/vsphere.md)

        export TF_DATA_DIR=${CK8S_CONFIG_PATH}/.state/.terraform
        export TF_VAR_ssh_pub_key=~/.ssh/id_rsa.pub
        export VSPHERE_USER=set-me
        export VSPHERE_PASSWORD=set-me
        export TF_WORKSPACE=glasswall-kubespray-jk

        terraform init -backend-config ${CK8S_CONFIG_PATH}/backend_config.hcl

        terraform apply -target module.service_cluster

7. Create ck8s workload cluster in vSphere

        terraform apply -target module.workload_cluster

8. Update `inventory.ini` files in `sc-config` and `wc-config` directories by setting `ansible_host` value to Public IP of respective machine.

### vSphere Storage Policy

Create a Storage Policy following the instructions [here](https://github.com/kubernetes/cloud-provider-vsphere/blob/master/docs/book/tutorials/kubernetes-on-vsphere-with-kubeadm.md#create-a-storage-policy)

1. Name and description

    Name: `Space-Efficient`

2. Policy structure

    Select `Enable host based rules`

3. Host based services

    Encryption, select: `Disabled`

    Storage I/O Control, select: `Normal IO share allocation`

4. Storage compatibility

    Make sure there is compatible storage available.

5. Click `Finish`

Configure VP Storage Policy for all the VMs:

1. Select the VM

2. Go to Configure tab

3. Click `EDIT VM STORAGE POLICIES`

4. Uncheck `Configure per disk` option

5. Select `Space-Efficient` value in the `VM storage policy` drop-down menu

6. Click `OK` button

### Install Kubernetes

Run in `gp-gov-uk-website/experiment-ck8s-metal`

    cd ../../../experiment-ck8s-metal

1. Prepare the environment:

    First run:

        sudo apt-get install python3-venv
        python3 -m venv venv

    Every run:

        source venv/bin/activate

2. Set the value of `supplementary_addresses_in_ssl_keys` field in `*c-config/group_vars/k8s-cluster.yaml` to the Public IP of respective master nodes (workload and service clusters).

3. Deploy Service Cluster:

        ./bin/ck8s-kubespray apply sc

4. Deploy Workload Cluster:

        ./bin/ck8s-kubespray apply wc

5. Exit python virtual environment

        deactivate

### Create vSphere CSI Storage Class

Run in `gp-gov-uk-website/compliantkubernetes-apps`

        cd ../compliantkubernetes-apps
        ./bin/ck8s ops kubectl sc create -f bootstrap/storageclass/manifests/vsphere-csi.yaml
        ./bin/ck8s ops kubectl wc create -f bootstrap/storageclass/manifests/vsphere-csi.yaml

### Install Compliant Kubernetes

Follow the instructions in [README file](compliantkubernetes-apps/README.md)

        export CK8S_CLOUD_PROVIDER=baremetal
        export CK8S_FLAVOR=dev
        export CK8S_CONFIG_PATH=~/workspace/glasswall/gp-gov-uk-website/ovh_glasswall-kubespray-jk

        ./bin/ck8s init

Edit `kube_config_sc.yaml` and `kube_config_wc.yaml` and set `clusters.cluster.server` to Public IPs.

        ./bin/ck8s apply sc
        ./bin/ck8s apply wc

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

## Debugging

Check if Public IPs are used in kubernetes config files:

        sudo grep --recursive "51.89.210." /etc/kubernetes/manifests/

Run kubectl within VM:

        sudo -s
        export KUBECONFIG=/etc/kubernetes/admin.conf
        kubectl get pods -A

        docker run --rm --name kubectl -v /etc/kubernetes/admin.conf:/.kube/config bitnami/kubectl:latest

        docker run --rm -it -v /var/lib/cloud/instance:/workdir mikefarah/yq:3 yq r user-data.txt runcmd

        sudo cat /var/lib/cloud/instance/user-data.txt

        ./bin/ck8s ops kubectl wc patch daemonset fluentd-fluentd-elasticsearch -n fluentd --type merge --patch ../patch-fluentd-domain.yaml

        ./bin/ck8s ops kubectl wc get daemonset fluentd-fluentd-elasticsearch -n fluentd -o yaml

        ./bin/ck8s ops kubectl wc set env daemonset.apps/fluentd-fluentd-elasticsearch -n fluentd OUTPUT_HOST=elastic.ops.MY-NEW-DOMAIN.com