# Terraform Enterprise Common Kubernetes Configuration

The Terraform Enterprise Helm chart supports a number of optional and common configuration options that may be appropriate for your operating environment.

## Custom Ingress
This Helm chart supports an optional ingress resource with your Ingress controller. To enable this, update the values in the `ingress` section on the values file, also setting `ingress.enabled` to `true`.

**Example setup with Nginx:**
* Install [nginx controller](https://kubernetes.github.io/ingress-nginx/deploy/) in a different namespace.
* Deploy Terraform Enterprise with Ingress already enabled on the Helm chart as explained above.
* Get the address from the ingress resource. e.g:
  ```
  kubectl get ingress
  NAME                   CLASS   HOSTS                                             ADDRESS         PORTS     AGE
  terraform-enterprise   nginx   terraform-enterprise.terraform-enterprise.svc.cluster.local   35.237.89.185   80, 443   60s
  ```
* Make this address routable to your Terraform Enterprise URL (`terraform-enterprise.terraform-enterprise.svc.cluster.local` in this example) by setting up a DNS record to point to it.
