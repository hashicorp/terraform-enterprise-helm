# Terraform Enterprise

This chart is used to install Terraform Enterprise in a generic Kubernetes environment. It is minimal in its configuration and contains the basic things necessary to launch Terraform Enterprise on a Kubernetes cluster.

## Prerequisites

To use the charts here, [Helm](https://helm.sh/) must be configured for your
Kubernetes cluster. Setting up Kubernetes and Helm is outside the scope of
this README. Please refer to the Kubernetes and Helm documentation.

The versions required are:

  * **Helm 3.0+** - This is the earliest version of Helm tested. It is possible
    it works with earlier versions but this chart is untested for those versions.
  * **Kubernetes 1.25+** - This is the earliest version of Kubernetes tested.
    It is possible that this chart works with earlier versions but it is
    untested.

## Usage

### Before You Begin
Please confirm that you have an operating Kubernetes cluster and that your local kubectl client is configured to operate that cluster. Also confirm that helm is configured appropriately.

```sh
kubectl cluster-info
helm list
```

You'll need the following to continue:

1. A hostname for your TFE instance and some way to provision DNS for this hostname such that, at a minimum, Terraform Enterprise is addressable from your workstation and any pod provisioned inside your Kubernetes cluster. The former is required in order for your workstation to communicate with the Terraform Enterprise installation created here. The later is required in order for tfc-agent instances provisioned for Terraform Enterprise workloads to be able to communicate with the Terraform Enterprise services they require to operate.
1. With the exception of a small number of cases you will need a way to create a dns address for the resulting Terraform Enterprise load balancer public ip address. This DNS address does not need to be generally publicly available, but it does need to be visible to the following use cases:
    * A user interacting with Terraform Enterprise
    * The terraform-enterprise pods within your Kubernetes cluster
    * The agent pods generated for plan / apply activity within your Kubernetes cluster
    * Any additional persistent agents added to your Terraform Enterprise instance or any additional Kubernetes clusters in which agents will be provisioned.
1. A valid TLS certificate and private key provisioned and matching the hostname selected in **1.** in pem format
1. External dependencies : Terraform Enterprise must run under the `external` or `active-active` operational mode when the Kubernetes driver used. The following prerequisite services must be available and configured prior to installing terraform-enterprise:
    * A PostgreSQL server meeting the requirements outlined in [PostgreSQL Requirements for Terraform Enterprise](https://developer.hashicorp.com/terraform/enterprise/requirements/data-storage/postgres-requirements)
    * S3 compatible object storage meeting the requirements outlined in the external services mode section of [Operational Mode Data Storage Requirements](https://developer.hashicorp.com/terraform/enterprise/requirements/data-storage/operational-mode-requirements#external-services-mode).
    * If Terraform Enterprise is running in `active-active` mode then a Redis cache instance is required also meeting the guidance in the above article.


### Create Prerequisites

1. Clone this repository
1. Create a namespace for terraform-enterprise:
    ```sh
    # Here, terraform-enterprise is the name of the custom namespace.
    kubectl create namespace terraform-enterprise
    ```
1. Create an image pull secret to fetch the `terraform-enterprise` container image from the beta registry. For example, you can create this secret by running this command:
    ```sh
    # replace REGISTRY_USERNAME, REGISTRY_PASSWORD, REGISTRY_URL with appropriate values
    kubectl create secret docker-registry terraform-enterprise --docker-server=REGISTRY_URL --docker-username=REGISTRY_USERNAME --docker-password=REGISTRY_PASSWORD  -n terraform-enterprise
    ```

### Update Chart Configuration

Create a configuration file (`/tmp/overrides.yaml` for the rest of this document) to override the default configuration values in the terraform-enterprise helm chart. **Replace all of the values in this example configuration.**

```yaml
tls:
  certData: BASE_64_ENCODED_CERTIFICATE_PEM_FILE
  keyData: BASE_64_ENCODED_CERTIFICATE_PRIVATE_KEY_PEM_FILE
image:
 repository: REGISTRY_URL
 name: terraform-enterprise
 tag: cab3e8f
env:
  TFE_HOSTNAME: "tfe.terraform-enterprise.service.cluster.local"
  TFE_OPERATIONAL_MODE: "external"

```
> :information_source:  There may be additional customization required for the database credentials, s3 compatible storage configuration, Redis configuration, etc that are often cloud provider or implementation specific.  See [Implementation Examples](docs/implementations.md#implementation-examples) for more information.

> :information_source:  Base64 values for files can be generated by using the `base64` utilitiy. For example: `base64 -i fixtures/tls/privkey.pem`

Add to the `env` entries any configuration required for database, object storage, Redis, or any additional configuration required for your environment. See [Terraform Enterprise Configuration Options](docs/configuration.md#terraform-enterprise-configuration-options) and [Implementation Examples](docs/implementations.md#implementation-examples) for more information.

### Install Terraform Enterprise

This document will assume that the copy of the terraform-enterprise-helm chart is at `./terraform-enterprise-helm`. Install terraform-enterprise-helm: 
```sh
helm install terraform-enterprise ./terraform-enterprise-helm -n terraform-enterprise  --values /tmp/overrides.yaml
```
> :information_source:  The `-n` is for setting a namespace, if no namespace is specified and you did not create a namespace as part of the steps in the prerequisites, the namespace will be automatically set to `default`.

During installation, the helm client will print useful information about which resources were created, what the state of the release is, and also whether there are additional configuration steps you can or should take.

By default, Helm does not wait until all of the resources are running before it exits. Many charts require Docker images that are over 600M in size, and may take additional time to install into the cluster. You can use the `--wait` and `--timeout` flags in helm install to force helm to wait until a minimum number of deployment replicates have passed their health-check based readiness checks before helm returns control to the shell.

To keep track of a release's state, or to re-read configuration information, you can use [helm status](https://helm.sh/docs/helm/helm_status/), IE:

```sh
  helm status terraform-enterprise -n terraform-enterprise
```
    
> :information_source:  When using helm commands, make sure to specify the namespace you created when using the `-n` flag. For this example we are use `terraform-enterprise`.

## Post install
There are a number of common helm or kubectl commands you can use to monitor the installation and the runtime of Terraform Enterprise. We list some of them here. We assume that the namespace is `terraform-enterprise`. If you have a different namespace, replace it with yours.

* To see releases:
  ```sh
  helm list -n terraform-enterprise
  ```

* To check the status of the Terraform Enterprise pod:
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
* In the Terraform Enterprise pod, run:
  ```sh
  supervisorctl status
  ```
  This should show you which service failed. From outside the pod you can also do this:
  ```sh
  kubectl exec -it terraform-enterprise-5946d99fc-l22s9 -- supervisorctl status
  ```

* All Terraform Enterprise services logs can be found in the pod here `/var/log/terraform-enterprise/`. E.g:
  ```sh
  cat /var/log/terraform-enterprise/atlas.log
  ```
  From outside the pod, this will be:
    ```sh
    kubectl exec -it terraform-enterprise-5946d99fc-l22s9 -- cat /var/log/terraform-enterprise/atlas.log
    ```

## Bootstrap Terraform Enterprise


TODO: Docs on creating your first admin user

# Unedited Below This Line
content below this section is unedited in this documentation review and will be visited for consideration shortly.


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
* Deploy Terraform Enterprise with Ingress already enabled on the Helm chart as explained above.
* Get the address from the ingress resource. e.g:
  ```
  kubectl get ingress
  NAME                   CLASS   HOSTS                                             ADDRESS         PORTS     AGE
  terraform-enterprise   nginx   terraform-enterprise.jkerryca.svc.cluster.local   35.237.89.185   80, 443   60s
  ```
* Make this address routable to your Terraform Enterprise URL (`terraform-enterprise.jkerryca.svc.cluster.local` in this example) by setting up a DNS record to point to it.

## Custom Agent Image

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

## Process for Upgrading Terraform Enterprise with Helm using the image tag

In the resulting folder, go to the directory named after your chart.

Inspect the values from the Terraform Enterprise K8s cluster, by running:

    helm get values terraform-enterprise -n <NAMESPACE>

After inspecting the helm values, print the output to an override.yaml file, by running:

    helm get values terraform-enterprise -n <NAMESPACE>  > override.yaml

Inside the override.yaml file, update the image tag to the version you want for the Terraform Enterprise upgrade and save the file.

To upgrade Terraform Enterprise, run the following commands:

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

## Helm Rollback process for Terraform Enterprise using the image tag

To rollback a Terraform Enterprise release we'll use the same approach as upgrading, by using the image tag. Make sure you have a current override.yaml file, if not print out the following command:

    helm get values terraform-enterprise -n <NAMESPACE>  > override.yaml

Once you've updated the image tag to the version you want to rollback to, execute the rollback process by running the following command:

    helm rollback terraform-enterprise -n <NAMESPACE>

Check the status and version history by running:

    helm history terraform-enterprise -n <NAMESPACE>

Check the deployment status of the pods using the following command:

    kubectl get nodes -n <NAMESPACE>

Note: Depending on how quickly you check the status after running the upgrade, the pods may still be getting recreated.
