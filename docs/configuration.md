# Terraform Enterprise Application Configuration Options

## Custom Agent Image

Terraform Enterprise pulls the publicly available [hashicorp/tfc-agent:latest](https://hub.docker.com/r/hashicorp/tfc-agent) image when kubernetes jobs are scheduled to execute plans and applies. If a custom tfc-agent image is required or the tfc-agent image should be pulled from a private container registry you can set the following environment variables:

* `TFE_RUN_PIPELINE_IMAGE` : The tfc-agent path. This can include a private registry source. eg. `privateregistry.azurecr.io/tfc-agent:latest`
* `TFE_RUN_PIPELINE_KUBERNETES_IMAGE_PULL_SECRET_NAME` : The name of an ImagePullSecret in the `[namespace]-agents` namespace to use when pulling the custom source tfc-agent image.

If an ImagePullSecret is required to access a private repository you must create the secret within the `[namespace]-agents` namespace after this helm chart has installed, but before attempting a plan or apply. See [Prerequisites](#prerequisites) for instructions for creating ImagePullSecrets.

## Custom CA Certificates

Terraform Enterprise supports the addition of custom CA certificates to the application runtime in oder to facilitate private certificate authorities in secure or restricted environments. These are exposed to the application as a pem formatted file mounted at runtime. This helm chart eases the management of the contents of this file mount and the path at which it is mounted by exposing the following values:

```yaml
tls:
  caCertBaseDir: /etc/ssl/certs
  caCertFileName: custom_ca_certs.pem
  caCertData: BASE_64_ENCODED_CA_CERTIFICATE
```

The contents of this file are appended to the terraform-enterprise container CA certificates file. Agent images are then instantiated with the entirety of this combined CA certificate file fully replacing the native container operating system's CA certificate file. This allows tfc-agent to communicate with any dependent services or endpoints that might signed with your private certificate authorities, including Terraform Enterprise itself.