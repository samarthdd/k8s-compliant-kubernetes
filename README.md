# gp-gov-uk-website

## Deployment instructions

### Create infrastructure

1. Source your environment file

        source jk-setup-env.sh

2. Initialize kubespray environment:

        cd compliantkubernetes-kubespray
        ./bin/ck8s-kubespray init sc default ~/.ssh/id_rsa.pub
        ./bin/ck8s-kubespray init wc default ~/.ssh/id_rsa.pub

3. Move to the terraform tfe directory

        cd ../ck8s-cluster/terraform/tfe

4. Export TF variables

        export TF_DATA_DIR=${CK8S_CONFIG_PATH}/.state/.terraform-tfe
        export TF_STATE=${CK8S_CONFIG_PATH}/.state/terraform-tfe.tfstate
        export TF_WORKSPACE=ck8s-ovh-glasswall-kubespray-jk-149

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
        export TF_WORKSPACE=glasswall-kubespray-jk-149

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

Run in `gp-gov-uk-website/compliantkubernetes-kubespray`

    cd ../../../compliantkubernetes-kubespray

1. Set the value of `supplementary_addresses_in_ssl_keys` field in `*c-config/group_vars/k8s-cluster.yaml` to the Public IP of respective master nodes (workload and service clusters).

2. Deploy Service Cluster:

        ./bin/ck8s-kubespray apply sc

3. Deploy Workload Cluster:

        ./bin/ck8s-kubespray apply wc

### Fix IPs in kubeconfig files

Edit `kube_config_sc.yaml` and `kube_config_wc.yaml` and set `clusters.cluster.server` to Public IPs.

        cd ../ovh_glasswall-kubespray-jk/
        sops -i -d .state/kube_config_wc.yaml
        vi .state/kube_config_wc.yaml
        sops -i -e .state/kube_config_wc.yaml

### Create vSphere CSI Storage Class (service cluster)

Run in `gp-gov-uk-website/compliantkubernetes-apps`

        cd ../compliantkubernetes-apps
        ./bin/ck8s ops kubectl sc create -f bootstrap/storageclass/manifests/vsphere-csi.yaml

### Create local storage PV (workload cluster)

Run in `gp-gov-uk-website/compliantkubernetes-apps`

        cd ../compliantkubernetes-apps
        ./bin/ck8s ops kubectl wc apply -f ../local-storage-pv.yaml

### Install Compliant Kubernetes

Follow the instructions in [README file](compliantkubernetes-apps/README.md)

        export CK8S_CLOUD_PROVIDER=baremetal
        export CK8S_FLAVOR=dev
        export CK8S_CONFIG_PATH=~/workspace/glasswall/gp-gov-uk-website/ovh_glasswall-kubespray-jk

        ./bin/ck8s init

        ./bin/ck8s apply sc
        ./bin/ck8s apply wc

### Fix directory ownership

In the VM run command:

        sudo chown -R 1000:1000 /mnt/disks/

### Glasswall ICAP

Also, Glasswall ICAP components require running as root, so some of the checks in the restricted PSP has to be relaxed.

1. Relax PodSecurityPolicy:

        cd compliantkubernetes-apps
        ./bin/ck8s ops kubectl wc apply -f ../default-restricted-psp.yaml

2. Deploy Glasswall ICAP components:

        ./bin/ck8s ops helmfile wc -f ../wip-helmfile-glasswall-icap.yaml apply

3. Create TLS key pair

        openssl req -newkey rsa:2048 -nodes -keyout tls.key -x509 -days 365 -out certificate.crt

4. Upload the TLS key pair

        ./bin/ck8s ops kubectl wc create secret tls icap-service-tls-config --namespace icap-adaptation --key tls.key --cert certificate.crt

5. Delete `frontend-icap-lb` service

        ./bin/ck8s ops kubectl wc delete service frontend-icap-lb -n icap-adaptation

6. Edit `icap-service` and set `nodePort` values to `1344` and `1345` respectively

        ./bin/ck8s ops kubectl wc edit service/icap-service -n icap-adaptation

7. Make sure that record in AWS Hosted Zones are configured properly.

## Testing ICAP service

To test the ICAP service run the following command:

        c-icap-client -f /home/jakub/Downloads/FIVB_VB_Scoresheet_2013_updated2.pdf -i icap.glasswall-ck8s-proxy.com -p 1344 -s gw_rebuild -o ./rebuilt.pdf -v

To test the ICAP service with TLS run the following command:

        docker run -it --rm -v /home/jakub/Downloads:/opt -v /home/jakub/Downloads:/home glasswallsolutions/c-icap-client:manual-v1 -s 'gw_rebuild' -i icap-149.glasswall-ck8s-proxy.com -p 1345 -tls -tls-method TLSv1_2 -tls-no-verify -f '/opt/FIVB_VB_Scoresheet_2013_updated2.pdf' -o '/opt/rebuilt.pdf' -v

## Delete ICAP deployment

        ./bin/ck8s ops helmfile wc -f ../wip-helmfile-glasswall-icap.yaml destroy

To force delete objects you can use:

        ./bin/ck8s ops kubectl wc -n icap-adaptation delete all --all
        ./bin/ck8s ops kubectl wc -n icap-adaptation delete pvc --all

## Update ICAP request processing

cd ../icap-request-processing/

Download the newest version of Glasswall Rebuild SDK from https://github.com/filetrust/sdk-rebuild-eval

https://github.com/filetrust/sdk-rebuild-eval/raw/master/libs/rebuild/linux/libglasswall.classic.so
https://github.com/filetrust/sdk-rebuild-eval/raw/master/libs/rebuild/windows/glasswall.classic.dll

place the file in respective folders

        lib/linux/SDK/
        lib/windows/SDK/

Rebuild the Docker image and push to the repository

        docker build . -t elastisys/icap-request-processing:runasroot
        docker push elastisys/icap-request-processing:runasroot

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