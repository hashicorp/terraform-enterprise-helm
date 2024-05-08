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

## Additional Documentation

For more information about Terraform Enterprise and the capabilities of this helm chart please see the following additional documentation:

* [Dependency Free Terraform Enterprise Quickstart Guide](docs/quickstart.md#dependency-free-terraform-enterprise-quickstart-guide)
* [Terraform Enterprise Application Configuration Options](docs/configuration.md#terraform-enterprise-application-configuration-options)
* [Examples of Common Implementations](docs/implementations.md#implementation-examples)
* [Terraform Enterprise Common Kubernetes Configuration](docs/kubernetes_configuration.md#terraform-enterprise-common-kubernetes-configuration)
