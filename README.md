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

## Custom Worker Image

Terraform Enterprise pulls the publicly available [hashicorp/tfc-agent:latest](https://hub.docker.com/r/hashicorp/tfc-agent) image when kubernetes jobs are scheduled to execute plans and applies. If a custom tfc-agent image is required or the tfc-agent image should be pulled from a private container registry you can set the following environment variables:

* `TFE_RUN_PIPELINE_IMAGE` : The tfc-agent path. This can include a private registry source. eg. `privateregistry.azurecr.io/tfc-agent:latest`
* `TFE_RUN_PIPELINE_KUBERNETES_IMAGE_PULL_SECRET_NAME` : The name of an ImagePullSecret in the `[namespace]-agents` namespace to use when pulling the custom source tfc-agent image.

If an ImagePullSecret is required to access a private repository you must create the secret within the `[namespace]-agents` namespace after this helm chart has installed, but before attempting a plan or apply. See [Prerequisites](#prerequisites) for instructions for creating ImagePullSecrets. 

## helm upgrade

The upgrade arguments must be a release and chart or update SHAs in the helm values. The chart argument can be either: a chart reference(`charts/terraform-enterprise`), a path to a chart directory, a packaged chart, or a fully qualified URL. For chart references, the latest version will be specified unless the `--version` flag is set.

This is a generic command to upgrade a release:

    helm upgrade [RELEASE] [CHART] [flags]

If you want to wait until the pods become ready, you can use a `--wait` flag

    helm upgrade <release-name> hashicrop/terraform-enterprise \
     --version <target-helm-chart-version> \
     --reuse-values \
     --wait \
     --namespace <namespace>

To override values in a chart, use either the `--values` flag and pass in a file or use the `--set` flag and pass configuration from the command line, to force string values, use `--set-string`. You can use `--set-file` to set individual values from a file when the value itself is too long for the command line or is dynamically generated. If a namespace is set, make sure to use the `-n` flag along with the name of the namespace.

    helm upgrade -f values.yaml -f override.yaml terraform-enterprise -n <NAMESPACE>

If you want Helm to rollback installation if it fails, you can use the `--atomic flag`. Note that the `--wait` flag will be set automatically if `--atomic` is used.

    helm upgrade -f my-values.yaml ./path/to/my/chart --install --atomic -n <NAMESPACE> 

## Helm rollback to previous release

The first argument of the rollback command is the name of a release, and the second is a revision (version) number. If this argument is omitted, it will roll back to the previous release.

To see revision numbers, run `helm history RELEASE`  or `helm ls`.

    helm rollback <RELEASE_NAME> -n <NAMESPACE>

Note: The helm rollback command is recommended because using the kubectl command will only rollback the deployment, but not other resources associated with helm release.

But if you need to rollback to specific previous version, You can:

List revision numbers by running:

    helm history <RELEASE_NAME>

Then, rollback to the version you want using:

    helm rollback <RELEASE_NAME> [REVISION]

## Process for Upgrading TFE with Helm using the image tag

In the resulting folder, go to the directory named after your chart.

Inspect the values from the TFE K8s cluster, by running:

    helm get values terraform-enterprise -n <NAMESPACE>

After inspecting the helm values, print the output to an override.yaml file, by running:

    helm get values terraform-enterprise -n <NAMESPACE>  > override.yaml

Inside the override.yaml file, update the image tag to the version you want for the TFE upgrade and save the file.

To upgrade TFE, run the following commands:

    helm upgrade -f values.yaml -f override.yaml terraform-enterprise -n <NAMESPACE> .

Check the status and version history by running:

    helm history terraform-enterprise -n <NAMESPACE>

Check the deployment status of the pods using the following command:

    kubectl get nodes -n <NAMESPACE>

You should see multiple revisions and an upgrade complete description, for example:

```
REVISION        UPDATED                         STATUS          CHART                           APP VERSION     DESCRIPTION
1               Thu Mar 30 21:07:26 2023        superseded      terraform-enterprise-0.1.0      1.16.0          Install complete
2               Thu Mar 30 14:23:21 2023        deployed        terraform-enterprise-0.1.0      1.16.0          Upgrade complete
```

Note: Depending on how quickly you check the status after running the upgrade, the pods may still be getting recreated.

## Helm Rollback process for TFE using the image tag

To rollback a TFE release we'll use the same approach as upgrading, by using the image tag. Make sure you have a current override.yaml file, if not print out the following command:

    helm get values terraform-enterprise -n <NAMESPACE>  > override.yaml

Once you've updated the image tag to the version you want to rollback to, execute the rollback process by running the following command:

    helm rollback terraform-enterprise -n <NAMESPACE>

Check the status and version history by running:

    helm history terraform-enterprise -n <NAMESPACE>

Check the deployment status of the pods using the following command:

    kubectl get nodes -n <NAMESPACE>

Note: Depending on how quickly you check the status after running the upgrade, the pods may still be getting recreated.
