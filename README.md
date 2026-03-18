# Terraform Enterprise

This chart is used to install Terraform Enterprise in a generic Kubernetes environment. It is minimal in its configuration and contains the basic things necessary to launch Terraform Enterprise on a Kubernetes cluster.

## Support for forking
This helm chart aims to meet the needs of the majority of our users. You are welcome to fork our helm chart and adapt it to your organization’s requirements. 

If you contact HashiCorp support, include your custom helm chart alongside your support bundle to ensure support has all the information they need.

## Prerequisites

To use the charts here, [Helm](https://helm.sh/) must be configured for your
Kubernetes cluster. Setting up Kubernetes and Helm are outside the scope of
this README. Please refer to the Kubernetes and Helm documentation.

The versions required are:

  * **Helm 3.0+** - This is the earliest version of Helm tested. It is possible
    it works with earlier versions but this chart is untested for those versions.
  * **Kubernetes 1.25+** - This is the earliest version of Kubernetes tested.
    It is possible that this chart works with earlier versions but it is
    untested.

## Instructions

Complete documentation and instructions for the installation of Terraform Enterprise can be found on the [Terraform Enterprise developer site](https://developer.hashicorp.com/terraform/enterprise/flexible-deployments/install).

## Helpful Commands
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

## Pre-upgrade Validation

Before performing a full Helm upgrade to a new version of Terraform Enterprise, you can run an independent, one-shot Kubernetes Job to validate your infrastructure and configuration.

The chart supports two safe execution paths using `preupgradeCheck.tfeNamespace`:

1. `true` (default): run in the existing TFE deployment namespace, strictly non-mutating for shared Terraform Enterprise resources. It renders only the preupgrade Job (and optional preupgrade override Secret).
2. `false`: run in a namespace without an existing TFE deployment. It renders only the minimum prerequisites for the preupgrade Job (ConfigMap/Secret, and ServiceAccount when enabled) plus the Job.

### Existing Namespace (Strict Non-Mutating)

1. Render and apply the preupgrade check resources:
   ```sh
   helm template <release> hashicorp/terraform-enterprise \
     --version <new-version> \
     -f production-values.yaml \
     --set preupgradeCheck.enabled=true \
     --set preupgradeCheck.tfeNamespace=true \
     --show-only templates/preupgrade-check-job.yaml \
     --show-only templates/preupgrade-check-secret.yaml \
     | kubectl apply -n <namespace> -f -
   ```

2. Monitor and inspect logs:
   ```sh
   kubectl wait --for=condition=complete \
     job/terraform-enterprise-preupgrade-check \
     -n <namespace> --timeout=300s

   kubectl logs -l app=terraform-enterprise-preupgrade-check \
     -n <namespace>
   ```

3. Clean up:
   ```sh
   kubectl delete job/terraform-enterprise-preupgrade-check \
     -n <namespace> --ignore-not-found
   kubectl delete secret/terraform-enterprise-preupgrade-check-overrides \
     -n <namespace> --ignore-not-found
   ```

4. Proceed with upgrade if validation succeeds:
   ```sh
   helm upgrade <release> hashicorp/terraform-enterprise \
     --version <new-version> -f production-values.yaml
   ```

Optional custom Job naming:
```sh
--set preupgradeCheck.jobName=terraform-enterprise-preupgrade-check-2.0.0
```
When `jobName` is set, use that exact name in `kubectl wait/delete` commands. The
override Secret name becomes `<jobName>-overrides`.

### Fresh Namespace Validation
Recommended when possible. This mode keeps preupgrade validation isolated and lets you clean everything with a single `helm uninstall`.

If your registry requires credentials, create the `imagePullSecrets` in the fresh namespace first.

```sh
helm install tfe-validation hashicorp/terraform-enterprise \
  -n tfe-validation --create-namespace \
  --version <target-version> \
  -f your-production-values.yaml \
  --set preupgradeCheck.enabled=true \
  --set preupgradeCheck.tfeNamespace=false
```

Cleanup:
```sh
helm uninstall tfe-validation -n tfe-validation
```

## Additional Documentation

For more information about Terraform Enterprise and the capabilities of this helm chart please see the following additional documentation:

* [Dependency Free Terraform Enterprise Quickstart Guide](docs/quickstart.md#dependency-free-terraform-enterprise-quickstart-guide)
* [Terraform Enterprise Application Configuration Options](docs/configuration.md#terraform-enterprise-application-configuration-options)
* [Examples of Common Implementations](docs/implementations.md#implementation-examples)
* [Terraform Enterprise Common Kubernetes Configuration](docs/kubernetes_configuration.md#terraform-enterprise-common-kubernetes-configuration)
