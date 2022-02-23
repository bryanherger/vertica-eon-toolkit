# Deploying Vertica on Vultr Kubernetes Engine (VKE)

## About Vertica

Vertica is an industry-leading analytics platform providing fast, flexible, extensible, and SQL-compatible analytics on data lakes and data warehouses.  Learn more about Vertica at https://www.vertica.com/about/

Vertica's architecture separates compute and storage allows cost-effective, scalable, secure and performant operation on cloud and containerized platforms like Kubernetes.  Vertica provides comprehensive open-source tooling to enable deployment and management on Kuberenetes, which we will demonstrate in this exercise. 

## Deploying Vertica on VKE

To demonstrate the flexibility and compatibility of Vertica on Kubernetes and S3 object storage, this repository shows how to deploy Vertica on Vultr, a cloud platform that provides S3 object storage and Kubernetes infrastructure that meet standards but are not officially supported.

Prerequisities for Vertica deployment:

- Configure a Vertica client: vsql CLI, ODBC/JDBC drivers, and others available from https://www.vertica.com/download/vertica/client-drivers/
- Set up an account at https://my.vultr.com/
- Create an object store with an S3 bucket under Objects and obtain the access and secret keys as well as bucket endpoint and S3 path.
- Create a Kubernetes cluster (minimum 3 Cloud Compute nodes with 2 CPU / 4 GB RAM each) and download the cluster YAML configuration.
- Install kubectl and helm locally to manage the Kubernetes cluster.  Ensure that kubectl uses the VKE cluster YAML configuration file.

The deployment largely follows Vertica documentation posted at https://www.vertica.com/docs/11.0.x/HTML/Content/Authoring/Containers/Kubernetes/ContainerizedVerticaWithK8s.htm
Please refer to the documentation for all possible options.  The following steps will create a minimally configured Vertica cluster.

Install cert-manager:

`$ kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.5.3/cert-manager.yaml`

Verify cert-manager is running:

```
$ kubectl get pods --namespace cert-manager
NAME                                       READY   STATUS    RESTARTS   AGE
cert-manager-7dd5854bb4-skks7              1/1     Running   5          12d
cert-manager-cainjector-64c949654c-9nm2z   1/1     Running   5          12d
cert-manager-webhook-6bdffc7c9d-b7r2p      1/1     Running   5          12d
```

Configure the Vertica helm chart repository:

`$ helm repo add vertica-charts https://vertica.github.io/charts`

Update the repository to ensure you have the latest version:

`$ helm repo update`

Install the VerticaDB operator:

`$ helm install vdb-op vertica-charts/verticadb-operator`

Create a secret storing your S3 keys:

`$ kubectl create secret generic s3-creds --from-literal=accesskey=yourAccesskey --from-literal=secretkey=yourSecretkey`

Create a secret storing your dbadmin (superuser) password:

`$ kubectl create secret generic su-passwd --from-literal=password=yourPassword`

Create a YAML file "vertica.yaml" to configure a Vertica database - you must edit path and endpoint to match your environment:

```
apiVersion: vertica.com/v1beta1
kind: VerticaDB
metadata:
  name: vertica-demo
spec:
  initPolicy: Create
  superuserPasswordSecret: su-passwd
  communal:
    path: s3://bucket/path
    endpoint: https://ewr1.vultrobjects.com
    credentialSecret: s3-creds
  local:
    requestSize: 64Gi
  subclusters:
    - name: defaultsubcluster
      size: 3
      serviceType: LoadBalancer
      nodePort: 32001
```

Apply the YAML file:

`$ kubectl create -f <vertica.yaml>`

Check service status:

`$ kubectl get svc`

When the service is up and external IP and port are available, you will be able to connect as dbadmin with your Vertica client.
