# Terraform Enterprise Common Kubernetes Configuration

The Terraform Enterprise Helm chart supports a number of optional and common configuration options that may be appropriate for your operating environment.

## Graceful Shutdown

Enable `waitForDrain` to let a terminating pod drain its active work before
shutdown. This is disabled by default.

```yaml
waitForDrain:
  enabled: true
```

When a pod terminates, its `preStop` hook:

1. Waits 30 seconds so the load balancers has time to deregister the pod.
2. Runs `tfectl node drain`.
3. Polls `tfectl node tasks --json` every 5 seconds until
   `is_safe_to_terminate` is `true`.

### Termination Grace Period

With draining enabled, `terminationGracePeriodSeconds` defaults to `86400` (24 hours). This covers both the hook and container shutdown. 
Pods exit as soon as that work finishes; they do not wait the full 24 hours.

You can override `terminationGracePeriodSeconds` whether draining is enabled or
not. The minimum allowed value is `600` (10 minutes).

**Warning:** Task worker can take up to 24 hours to drain. A shorter grace period may cause Kubernetes to terminate TFE while runs are still active.:

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
