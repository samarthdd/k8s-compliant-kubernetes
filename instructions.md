# Deploy GW Cloud SDK with compliant kubernetes (worker and service cluster)

## Deployment instructions using AMI

Worker and service cluster AMIs are automatically created by running **CK8icap-GW_CloudSDK** workflow in GitHub Actions using Packer.
Amazon CloudFormation launch Template is provided  in the repository to facilitate configuration of the deployment.

- To launch instances click on one of the Buttons below and follow the steps


### Launching with Click of Button
| Region           | Stack                                                                                                                                                                                                                                                                                                                                      |
|------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Ireland          | [<img src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png">](https://console.aws.amazon.com/cloudformation/home?region=eu-west-1#/stacks/new?stackName=IcapLoadBalancerStack&templateURL=https://icap-cloudformation-template.s3-eu-west-1.amazonaws.com/Compliant_Kubernetes_ICAP_Service_with_Service_Cluster_Proxy_REST_API.json) |
| London          | [<img src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png">](https://console.aws.amazon.com/cloudformation/home?region=eu-west-2#/stacks/new?stackName=IcapLoadBalancerStack&templateURL=https://icap-cloudformation-template.s3-eu-west-1.amazonaws.com/Compliant_Kubernetes_ICAP_Service_with_Service_Cluster_Proxy_REST_API.json) |
| Frankfurt          | [<img src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png">](https://console.aws.amazon.com/cloudformation/home?region=eu-central-1#/stacks/new?stackName=IcapLoadBalancerStack&templateURL=https://icap-cloudformation-template.s3-eu-west-1.amazonaws.com/Compliant_Kubernetes_ICAP_Service_with_Service_Cluster_Proxy_REST_API.json) |
| Paris          | [<img src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png">](https://console.aws.amazon.com/cloudformation/home?region=eu-west-3#/stacks/new?stackName=IcapLoadBalancerStack&templateURL=https://icap-cloudformation-template.s3-eu-west-1.amazonaws.com/Compliant_Kubernetes_ICAP_Service_with_Service_Cluster_Proxy_REST_API.json) |
| Ohio  | [<img src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png">](https://console.aws.amazon.com/cloudformation/home?region=us-east-2#/stacks/new?stackName=IcapLoadBalancerStack&templateURL=https://icap-cloudformation-template.s3-eu-west-1.amazonaws.com/Compliant_Kubernetes_ICAP_Service_with_Service_Cluster_Proxy_REST_API.json) | 
| N. Virginia  | [<img src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png">](https://console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/new?stackName=IcapLoadBalancerStack&templateURL=https://icap-cloudformation-template.s3-eu-west-1.amazonaws.com/Compliant_Kubernetes_ICAP_Service_with_Service_Cluster_Proxy_REST_API.json) | 
| N. California  | [<img src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png">](https://console.aws.amazon.com/cloudformation/home?region=us-west-1#/stacks/new?stackName=IcapLoadBalancerStack&templateURL=https://icap-cloudformation-template.s3-eu-west-1.amazonaws.com/Compliant_Kubernetes_ICAP_Service_with_Service_Cluster_Proxy_REST_API.json) | 
| Oregon  | [<img src="https://s3.amazonaws.com/cloudformation-examples/cloudformation-launch-stack.png">](https://console.aws.amazon.com/cloudformation/home?region=us-west-2#/stacks/new?stackName=IcapLoadBalancerStack&templateURL=https://icap-cloudformation-template.s3-eu-west-1.amazonaws.com/Compliant_Kubernetes_ICAP_Service_with_Service_Cluster_Proxy_REST_API.json) | 



* When prompted with the image below, click Next

  ![Screenshot from 2021-03-25 17-13-06](https://user-images.githubusercontent.com/7603614/112506566-2fb20380-8d8e-11eb-9476-909cc8a751ed.png)

* Enter `Stack name` (less than 20 characters)

  ![Screenshot from 2021-03-25 17-13-45](https://user-images.githubusercontent.com/7603614/112506657-45bfc400-8d8e-11eb-91a9-59e3c0b558ef.png)

  Set **Credentials**:

  * `Service Cluster Key Name` and `Workload Cluster Key Name` to the names of key pairs (previously uploaded to AWS) that will be allowed to SSH into VMs

    ![Screenshot from 2021-03-25 17-14-04](https://user-images.githubusercontent.com/7603614/112506741-55d7a380-8d8e-11eb-8627-8427d194eeed.png)

  * `Logging Password`  Fluentd password

  * `Monitoring Password` to plain text of InfluxDB WC writer password

    The **Logging Password** & **Monitoring Password** are the elasticsearch.fluentdPassword & influxDB.wcWriterPassword Values respectively that are generated during the github action run which produced the used service cluster AMI

    ![pic2](https://user-images.githubusercontent.com/70108899/116323434-3fbe6800-a7be-11eb-975b-592d81187897.jpg)

    
  
  * **Service Cluster** specification mainly AMI ID and Instance size, make sure the AMI is the one generated in the same github action run where you get the logging and monitory passwords above.

    ![image](https://user-images.githubusercontent.com/17300331/116555949-8fb24180-a91a-11eb-8e1c-4bb506755a86.png)

  * **Workload Cluster** specification mainly AMI ID, Instance size and number of instances.

    ![image](https://user-images.githubusercontent.com/17300331/116556059-af496a00-a91a-11eb-8367-a03373ad08e2.png)


* When the stack creation is complete, in the **Outputs** tab you can find:
  * `Load Balancer DNS Name` which stand in-front of the workload cluster instances and accept requests on port `8080`
  * `Service Cluster IP`  that exposes Grafana on port `3000` and Kibana on port `5601`

  ![Screenshot from 2021-03-25 18-05-43](https://user-images.githubusercontent.com/7603614/112513618-ced9f980-8d94-11eb-9559-61cee07e7a93.png)


## Testing

* Testing workload cluster :

  * Send and http request to `<LoadBalancer DNS Name>:8080/api/health`  you should receive `200 OK` which indicates healthy workload cluster 

    ![pic1](https://user-images.githubusercontent.com/70108899/116323389-29181100-a7be-11eb-8fb4-5e8581e1b9db.jpg)

* Testing service cluster :

  * From your browser go to service cluster IP provided in the outputs tab above on port 3000 to access Grafana and on port 5601 to acces Kibana

  * **Grafana's Password** & **Kibana's Password** are the user.grafanaPassword & elasticsearch.adminPassword Values respectively that are generated during the github action run which produced the used service cluster AMI
