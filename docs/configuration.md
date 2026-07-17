# Terraform Enterprise Application Configuration Options

## Custom Agent Image

Terraform Enterprise pulls the publicly available [hashicorp/tfc-agent:latest](https://hub.docker.com/r/hashicorp/tfc-agent) image when kubernetes jobs are scheduled to execute plans and applies. The following variables are available to customize the source of a tfc-agent image and the credentials used when pulling that image:

* `TFE_RUN_PIPELINE_IMAGE` : The tfc-agent path. This can include a private registry source. eg. `privateregistry.azurecr.io/tfc-agent:latest`
* `TFE_RUN_PIPELINE_KUBERNETES_IMAGE_PULL_SECRET_NAME` : The name of an ImagePullSecret in the `[namespace]-agents` namespace to use when pulling the custom source tfc-agent image.

If an ImagePullSecret is required to access a private repository you must create the secret within the `[namespace]-agents` namespace after this helm chart has installed, but before attempting a plan or apply. See [Prerequisites](../README.md#prerequisites) for instructions for creating ImagePullSecrets.

### Debug mode

Terraform Enterprise immediately deletes Kubernetes jobs after their execution finishes. However, if something goes wrong
during the lifespan of these, it is possible to keep them alive for a limited amount of time. To configure this,
provide these environment variables to the chart:

* `TFE_RUN_PIPELINE_KUBERNETES_DEBUG_ENABLE`: boolean flag that will enable debug mode, and will consume all the settings
from the `TFE_RUN_PIPELINE_KUBERNETES_DEBUG_*` environment variables.
* `TFE_RUN_PIPELINE_KUBERNETES_DEBUG_JOBS_TTL`: time in seconds after which the jobs will get deleted. Default value
is 86400 e.g. 1 day.

## Custom CA Certificates

Terraform Enterprise supports the addition of custom CA certificates to the application runtime in oder to facilitate private certificate authorities in secure or restricted environments. These are exposed to the application as a `pem` formatted file mounted at runtime. This helm chart eases the management of the contents of this file mount and the path at which it is mounted by exposing the following values:

```yaml
tls:
  caCertBaseDir: /etc/ssl/certs
  caCertFileName: custom_ca_certs.pem
  caCertData: BASE_64_ENCODED_CA_CERTIFICATE
```

The contents of this file are appended to the terraform-enterprise container CA certificates file. Agent images are then instantiated with the entirety of this combined CA certificate file fully replacing the native container operating system's CA certificate file. This allows tfc-agent to communicate with any dependent services or endpoints that might signed with your private certificate authorities, including Terraform Enterprise itself.

## Redis mTLS Certificates

Terraform Enterprise supports mTLS connections to Redis instances for enhanced security. When using external Redis instances with mTLS enabled, you can configure the necessary certificates through the helm chart values. This feature supports both Redis Standalone and Redis Enterprise instances with separate certificate configurations.

### Redis TLS Configuration

```yaml
tlsRedis:
  certData: BASE_64_ENCODED_CLIENT_CERTIFICATE
  keyData: BASE_64_ENCODED_CLIENT_PRIVATE_KEY
  caCertData: BASE_64_ENCODED_CA_CERTIFICATE
```

### Redis Enterprise TLS Configuration

```yaml
tlsRedisSidekiq:
  certData: BASE_64_ENCODED_CLIENT_CERTIFICATE
  keyData: BASE_64_ENCODED_CLIENT_PRIVATE_KEY
  caCertData: BASE_64_ENCODED_CA_CERTIFICATE
```

## Metrics

Terraform Enterprise exposes metrics in json or Prometheus format. The `.Values.tfe.metrics.enable` value exposes the container ports for the metrics service, configures Terraform Enterprise to launch the metrics service, and annotates the Terraform Enterprise pods with common annotations required for Prometheus discovery and automated metrics scraping. More information about metrics can be found [in the Terraform Enterprise Metrics documentation](https://developer.hashicorp.com/terraform/enterprise/admin/infrastructure/monitoring).

Prometheus scrape annotations
```
apiVersion: v1
items:
- apiVersion: v1
  kind: Pod
  metadata:
    annotations:
      prometheus.io/path: /metrics
      prometheus.io/port: "9090"
      prometheus.io/scrape: "true"
    creationTimestamp: "2023-09-01T15:42:32Z"
    generateName: terraform-enterprise-546db68fcd-
    labels:
      app: terraform-enterprise
...
```

## Admin Console access mode

The `.Values.tfe.adminConsole.accessMode` value sets the Admin Console access
posture by rendering `TFE_ADMIN_CONSOLE_ACCESS_MODE` into the application
ConfigMap. Supported values are `port`, `both`, and `disabled`. Omitting the
value (the default empty string) preserves the legacy behaviour, in which the
Admin Console is served on the dedicated admin HTTPS port only.

| `accessMode`   | Dedicated admin port (`tfe.adminHttpsPort`) | Primary hostname `/platform/admin` |
| -------------- | ------------------------------------------- | ---------------------------------- |
| `port`         | UI + API                                    | off                                |
| `both`         | UI + API                                    | UI + API                           |
| `disabled`     | off                                         | off                                |
| _unset_ (`""`) | legacy: UI + API                            | off                                |

Any value other than `port`, `both`, `disabled`, or empty fails chart rendering
with an actionable error.

In `both` mode the Admin Console is served at `/platform/admin` on the primary
hostname over standard HTTPS. The default ingress routes all paths on the
primary host to the Terraform Enterprise service (a `/` `Prefix` rule), so
`/platform/admin/` is reachable without configuring a separate Admin Console
ingress.

> **Security — `both` exposes the privileged admin surface with no network
> restriction.** Because the default ingress routes every path to the TFE
> service, enabling `both` publishes the privileged Admin Console UI and Admin
> API on your primary hostname to anything that can reach the ingress. If you
> previously isolated the dedicated admin port with a firewall or
> `NetworkPolicy`, that protection no longer applies. A Kubernetes
> `NetworkPolicy` operates at L3/L4 and **cannot** restrict by URL path, so it
> cannot protect `/platform/admin` while keeping the rest of `:443` open — the
> restriction must be applied at the ingress/HTTP layer. Before enabling `both`:
>
> - restrict `/platform/admin` at the ingress controller (for example, an IP
>   allow-list annotation scoped to that path), and/or
> - set the TFE-side allow-list via `env.variables`:
>   `TFE_ADMIN_CONSOLE_STANDARD_ALLOW_CIDRS` (permitted client sources) together
>   with `TFE_ADMIN_CONSOLE_STANDARD_TRUSTED_PROXIES` (your ingress/LB addresses,
>   required so the allow-list matches the real client rather than the ingress).

```yaml
tfe:
  adminConsole:
    accessMode: both
env:
  variables:
    # Restore a network restriction on the shared :443 admin surface. Trusted
    # proxies are required behind an ingress so the allow-list matches the
    # client, not the ingress source address.
    TFE_ADMIN_CONSOLE_STANDARD_ALLOW_CIDRS: "10.20.0.0/16"
    TFE_ADMIN_CONSOLE_STANDARD_TRUSTED_PROXIES: "192.0.2.0/24"
```

## Custom agent worker pod template

Terraform Enterprise now supports the inclusion of a custom pod template via `agentWorkerPodTemplate` in the Values file.
With this, you can define your own specifications for the creation of the agent worker pods.
The custom pod template must be a valid `corev1.PodTemplateSpec` and should be provided in YAML format. The `PodTemplateSpec` is
documented at <https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-template-v1/#PodTemplateSpec>.


## Vault CSI Provider
Terraform Enterprise now supports [Vault CSI provider](https://developer.hashicorp.com/vault/docs/platform/k8s/csi). This allows TFE pods to consume Vault secrets using CSI Secrets Store volumes.

The settings for this can be found in the `values.yaml` file under the `csi` section.
If `csi.enabled` is set to true, the Vault CSI provider will be used to retrieve secrets, as it is the only supported provider. This requires using an external Vault.

The Secrets Store CSI Driver also supports syncing to Kubernetes secret objects. The `secretObjects` section adds secret syncing for TFE if values are provided.

**Note:** The Vault CSI Provider requires the [CSI Secret Store Driver](https://secrets-store-csi-driver.sigs.k8s.io/getting-started/installation.html) to be installed.
