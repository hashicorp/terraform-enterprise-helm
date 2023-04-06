# Terraform Enterprise

This chart is used to install Terraform Enterprise in a generic Kubernetes environment. It is extremely minimal in its configuration and contains the basic things necessary to launch TFE on a Kubernetes cluster.

## Prerequisites

1. [Helm CLI](https://helm.sh/docs/intro/install/) installed on your machine. You can read more about Helm [here](https://helm.sh/docs/intro/using_helm/).

2. Create a custom namespace. This can be done by running:
    ```sh
    # Here, terraform-enterprise is the name of the custom namespace.
    kubectl create namespace terraform-enterprise
    ```

3. Create an image pull secret to fetch the `terraform-enterprise` container from Quay. You can either create this secret by running this command _(replace QUAY_USERNAME and QUAY_PASSWORD with yours)_:
    ```sh
    kubectl create secret docker-registry terraform-enterprise --docker-server=quay.io --docker-username=QUAY_USERNAME --docker-password=QUAY_PASSWORD  -n terraform-enterprise
    ```
    Or by generating a yaml equivalent from a dry run and adding it to a new yaml file inside the `/chart/templates` directory.
    
    _To generate a dry run, do:_
    ```sh
    kubectl create secret docker-registry terraform-enterprise --docker-server=quay.io --docker-username=QUAY_USERNAME --docker-password=QUAY_PASSWORD  -n terraform-enterprise --dry-run=client -o yaml
    ```
    _Afterwards, create a file `docker.secret.yaml` inside `/chart/templates`, then copy the resulting yaml that was generated from the dry run command to that file._
    
    If you decided to add the image pull secret to `docker.secret.yaml`, the contents should look like this:
    ```yaml
    apiVersion: v1
    data:
      .dockerconfigjson: WW91IHJlYWxseSBoYWQgdG8gY2hlY2sgdGhpcyBvbmUgdG9vPyBXZSBoYXZlbid0IGVzdGFibGlzaGVkIGF0IHRoaXMgcG9pbnQgdGhhdCBJJ20gbm90IHdyaXRpbmcgc2VjcmV0cyB0byBnaXQ/Cg==
    kind: Secret
    metadata:
      name: terraform-enterprise
      namespace: terraform-enterprise
    type: kubernetes.io/dockerconfigjson
    ```
4. Create a file `cert.secret.yaml` in `/chart` directory. It should contain base64 encoded values of your `cert.pem` file (as `tls.crt`) and `key.pem` file (as `tls.key`) in this format:
```yaml
tls_crt: WW91IHJlYWxseSBoYWQgdG8gY2hlY2sgdGhpcyBvbmUgdG9vPyBXZSBoYXZlbid0IGVzdGFibGlzaGVkIGF0IHRoaXMgcG9pbnQgdGhhdCBJJ20gbm90IHdyaXRpbmcgc2VjcmV0cyB0byBnaXQ/Cg==
tls_key: WW91IHJlYWxseSBoYWQgdG8gY2hlY2sgdGhpcyBvbmUgdG9vPyBXZSBoYXZlbid0IGVzdGFibGlzaGVkIGF0IHRoaXMgcG9pbnQgdGhhdCBJJ20gbm90IHdyaXRpbmcgc2VjcmV0cyB0byBnaXQ/Cg==
```

Note: Terraform Kubernetes provider can also be used to build and assemble all of these prerequisites if properly bootstrapped.

## Install TFE

* On the root of this project directory (i.e `/chart`), run: 
    ```sh
    helm install terraform-enterprise . -n terraform-Enterprise  --values values.yaml --values cert.secret.yaml
    ```
    Note: The `-n` is for setting a namespace, if no namespace is specified and you did not create a namespace as part of the steps in the prerequisites, the namespace will be automatically set to `default`.

During installation, the helm client will print useful information about which resources were created, what the state of the release is, and also whether there are additional configuration steps you can or should take.

By default, Helm does not wait until all of the resources are running before it exits. Many charts require Docker images that are over 600M in size, and may take additional time to install into the cluster. You can use the `--wait` and `--timeout` flags in helm install to force helm to wait until a minimum number of deployment replicates have passed their health-check based readiness checks before helm returns control to the shell.

To keep track of a release's state, or to re-read configuration information, you can use `helm status`, IE:

```sh
  helm status terraform-enterprise -n terraform-enterprise
```
    
Note: When using helm commands, make sure to specify the namespace you created when using the `-n` flag. For this example we are use `terraform-enterprise`.

## Post install
The commands here assume that the namespace is `terraform-enterprise`. If you have a different namespace, replace it with yours.

* To see releases:
  ```sh
  helm list -n terraform-enterprise
  ```

* To check the status of the TFE pod:
  ```sh
    kubectl get pod -n terraform-enterprise
  ```
  In the output, the `STATUS` should be in `Running` state and the `READY`section should show `1/1`. e.g:
  ```sh
  NAME                                   READY   STATUS    RESTARTS   AGE
  terraform-enterprise-5946d99fc-l22s9   1/1     Running   0          25m
  ```
  If this is not the case, you can use the following steps to debug:
  * Check pod logs:
    ```sh
    kubectl logs terraform-enterprise-5946d99fc-l22s9
    ```
  * To diagnose issues with the terraform-enterprise deployment such as image pull errors, run the following command:
    ```sh
    kubectl describe deployments -n terraform-enterprise
    ```
  * Exec into the pod if possible:
    ```sh
    kubectl exec -it terraform-enterprise-5946d99fc-l22s9 -- /bin/bash
    ```
  * In the TFE pod, run:
    ```sh
    supervisorctl status
    ```
    This should show you which service failed. From outside the pod you can also do this:
    ```sh
    kubectl exec -it terraform-enterprise-5946d99fc-l22s9 -- supervisorctl status
    ```

  * All TFE services logs can be found in the pod here `/var/log/terraform-enterprise/`. E.g:
    ```sh
    cat /var/log/terraform-enterprise/atlas.log
    ```
    From outside the pod, this will be:
      ```sh
      kubectl exec -it terraform-enterprise-5946d99fc-l22s9 -- cat /var/log/terraform-enterprise/atlas.log
      ```

* You can use this endpoint `/admin/account/new?token=hashicorp` to create an admin user. (Token=hashicorp is hardcoded at the moment)

# Optional Configurations

## Kubernetes Dashboard UI

The Dashboard is a web-based Kubernetes user interface. You can use Dashboard to troubleshoot your containerized application and manage the cluster resources. Dashboard also provides information on the state of Kubernetes resources in your cluster and on any errors that may have occurred.

Note: If you want to access the Kubernetes Dashboard UI that displays detailed information for all workloads running in the cluster, you'll need to create a service account bearer token. For testing this locally, the URL to access the K8s dashboard UI will be set to localhost on port 8001.

Info: https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

## Service account bearer tokens

Service account bearer tokens are perfectly valid to use outside the cluster and can be used to create identities for long standing jobs that wish to talk to the Kubernetes API. To manually create a service account, use the kubectl create serviceaccount (NAME) command. This creates a service account in the current namespace.

 Create service account:

    $ kubectl create serviceaccount terraform-enterprise

 Create an associated token:

    $ kubectl create token terraform-enterprise

The created token is a signed JSON Web Token (JWT).

Info: https://kubernetes.io/docs/reference/access-authn-authz/authentication/#service-account-tokens

## Custom Ingress
This Helm chart supports an optional ingress resource with your Ingress controller. To enable this, update the values in the `ingress` section on the values file, also setting `ingress.enabled` to `true`.

**Example setup with Nginx:**
* Install [nginx controller](https://kubernetes.github.io/ingress-nginx/deploy/) in a different namespace.
* Deploy TFE with Ingress already enabled on the Helm chart as explained above.
* Get the address from the ingress resource. e.g:
  ```
  kubectl get ingress
  NAME                   CLASS   HOSTS                                             ADDRESS         PORTS     AGE
  terraform-enterprise   nginx   terraform-enterprise.jkerryca.svc.cluster.local   35.237.89.185   80, 443   60s
  ```
* Make this address routable to your TFE URL (`terraform-enterprise.jkerryca.svc.cluster.local` in this example) by setting up a DNS record to point to it.
