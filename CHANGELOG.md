## v2.0.4 (July 17th, 2026)
TFE application version: `2.0.4`
* Add `tfe.adminConsole.accessMode` chart value to control the Admin Console access posture (`port`, `both`, `disabled`, or `""` for legacy behaviour). Renders `TFE_ADMIN_CONSOLE_ACCESS_MODE` in the ConfigMap [#TF-38319](https://github.com/hashicorp/terraform-enterprise-helm/pull/210)
* Backport: Add configurable readiness probe timing (`tfe.readinessProbeInitialDelaySeconds`, `tfe.readinessProbePeriodSeconds`, `tfe.readinessProbeFailureThreshold`, `tfe.readinessProbeTimeoutSeconds`) [#208](https://github.com/hashicorp/terraform-enterprise-helm/pull/208)

## v1.6.10 (July 6th, 2026)
TFE application version: `1.2.4`
* Helm chart version bump to resolve index update trigger for the 1.2.4 release

## v1.6.8 (June 25th, 2026)
TFE application version: `1.2.3`
* Add `tfe.adminHttpsPort` value (default `8446`) and expose it as a container port and Service port (`admin-https-port`) on both primary and secondary services, including NodePort variants (`service.adminNodePort`, `serviceSecondary.adminNodePort`) [#TF-38319 prep](https://github.com/hashicorp/terraform-enterprise-helm/pull/196)
* Support `b64:` prefix for pre-encoded `env.secrets` values to prevent corruption when passing secrets through tooling that mangles special characters (e.g. ArgoCD `--set`) [#speter/env-secrets-b64-prefix](https://github.com/hashicorp/terraform-enterprise-helm/pull/195)

## v1.6.7 (May 5th, 2026)
TFE application version: `1.2.3`
* Bump appVersion to `1.2.3` (Terraform Enterprise v1.2.3 release)

## v1.6.6 (January 19th, 2026)
TFE application version: `1.1.4`
* Update readiness probe default path from `/_health_check` to `/api/v1/health/readiness` [#157](https://github.com/hashicorp/terraform-enterprise-helm/pull/157)
* Update MinIO dependency to version `5.4.0` / image tag `RELEASE.2025-10-15T17-29-55Z` [#153](https://github.com/hashicorp/terraform-enterprise-helm/pull/153)
* Add automated tag and release workflow [#152](https://github.com/hashicorp/terraform-enterprise-helm/pull/152)
* Add compliance copyright and license headers (batch 1) [#149](https://github.com/hashicorp/terraform-enterprise-helm/pull/149)
* Bump appVersion through `1.1.2` → `1.1.3` → `1.1.4`

## v1.6.5 (August 12th, 2025)
TFE application version: `v202507-1`
* Add `tlsSecondary.certificateSecret` support — allows referencing a pre-existing Kubernetes secret for the secondary hostname certificate instead of providing raw cert data [#129](https://github.com/hashicorp/terraform-enterprise-helm/pull/129)
* Add configurable secondary hostname (`tlsSecondary`) TLS support with `certMountPath` / `keyMountPath` [#129](https://github.com/hashicorp/terraform-enterprise-helm/pull/129)
* Increase default resource requests to `8192Mi` memory / `4000m` CPU [#133](https://github.com/hashicorp/terraform-enterprise-helm/pull/133)
* Remove `env.configFilePath` and `env.secretsFilePath` file-based config options [#120](https://github.com/hashicorp/terraform-enterprise-helm/pull/120)
* Bump appVersion to `v202507-1`

## v1.6.4 (July 14th, 2025)
TFE application version: `v202507-1`
* Add `agents.namespace.name` value — allows overriding the agent namespace name (defaults to `<release-namespace>-agents`) [#TF-27136](https://github.com/hashicorp/terraform-enterprise-helm/pull/134)
* Fix readiness probe to respect `tfe.readinessProbePath` and `tfe.readinessProbeScheme` values (was previously hardcoded) [#134](https://github.com/hashicorp/terraform-enterprise-helm/pull/134)
* Replace `appProtocol: https` hardcoded service value with configurable `service.appProtocol` (defaults to `tcp`) [#134](https://github.com/hashicorp/terraform-enterprise-helm/pull/134)

## v1.6.3 (June 10th, 2025)
TFE application version: `v202506-1`
* Bump appVersion to `v202506-1` [#132](https://github.com/hashicorp/terraform-enterprise-helm/pull/132)

## v1.6.2 (May 30th, 2025)
TFE application version: `v202505-1`
* Fix chart version (corrected version numbering after an accidental `1.7.0` bump) [#131](https://github.com/hashicorp/terraform-enterprise-helm/pull/131)
* Bump appVersion to `v202505-1` [#126](https://github.com/hashicorp/terraform-enterprise-helm/pull/126)

## v1.6.1 (April 22nd, 2025)
TFE application version: `v202504-1`
* Bump appVersion to `v202504-1` [#124](https://github.com/hashicorp/terraform-enterprise-helm/pull/124)
* Remove SOX check workflow

## v1.6.0 (March 17th, 2025)
TFE application version: `v202503-1`
* Integrate Secrets Store CSI Driver (Vault provider) as a secrets source option — new `csi.*` values block adds a `SecretProviderClass` template and mounts the CSI volume into the TFE container [#118](https://github.com/hashicorp/terraform-enterprise-helm/pull/118)
* Support `env.secretKeyRefs` and `env.configMapKeyRefs` to inject external Kubernetes secrets and ConfigMap entries as individual environment variables via `valueFrom` [#111](https://github.com/hashicorp/terraform-enterprise-helm/pull/111)
* Add compliance copyright and license headers to all templates [#122](https://github.com/hashicorp/terraform-enterprise-helm/pull/122)
* Bump appVersion to `v202503-1`

## v1.5.0 (February 20th, 2025)
TFE application version: `v202502-1`
* Add `pdb` values block — optionally creates a `PodDisruptionBudget` for the TFE deployment (`pdb.enabled`, `pdb.replicaCount`, `pdb.annotations`, `pdb.labels`) [#115](https://github.com/hashicorp/terraform-enterprise-helm/pull/115)
* Add `extraVolumes` and `extraVolumeMounts` values — allows attaching arbitrary volumes (e.g. cert-manager secrets, PVCs for persistent logs) to the TFE pod [#112](https://github.com/hashicorp/terraform-enterprise-helm/pull/112)
* Add `service.labels` value — adds labels to the TFE Service (useful for ServiceMonitor-based metrics collection) [#109](https://github.com/hashicorp/terraform-enterprise-helm/pull/109)
* Fix RBAC `RoleBinding` subject name to use `serviceAccount.name` when a custom service account name is provided [#93](https://github.com/hashicorp/terraform-enterprise-helm/pull/93)
* Bump appVersion to `v202502-1`

## v1.4.0 (January 16th, 2025)
TFE application version: `v202501-1`
* Add `extraVolumes` and `extraVolumeMounts` values to attach arbitrary volumes to the TFE pod [#112](https://github.com/hashicorp/terraform-enterprise-helm/pull/112)
* Add optional `service.labels` to the TFE Service [#109](https://github.com/hashicorp/terraform-enterprise-helm/pull/109)
* Fix RBAC RoleBinding for custom `serviceAccount.name` [#91](https://github.com/hashicorp/terraform-enterprise-helm/pull/91), [#93](https://github.com/hashicorp/terraform-enterprise-helm/pull/93)
* Bump appVersion to `v202501-1`

## v1.3.4 (November 26th, 2024)
TFE application version: `v202410-1`
* Fix `readinessProbePath` and `readinessProbeScheme` not being applied when `tfe.readinessProbePath` is unset — the Helm chart now correctly falls back to `/_health_check` and `HTTP` [#101](https://github.com/hashicorp/terraform-enterprise-helm/pull/101)
* Set `appProtocol` to `tcp` by default in the Service (configurable per-port), replacing the previous hardcoded `https` value; add Azure `appProtocol: tcp` guidance [#103](https://github.com/hashicorp/terraform-enterprise-helm/pull/103)
* Add CI linting via `kubeconform` to prevent merging invalid manifests [#102](https://github.com/hashicorp/terraform-enterprise-helm/pull/102)
* Document `TFE_REDIS_SIDEKIQ_*` example configuration in `values.yaml` [#98](https://github.com/hashicorp/terraform-enterprise-helm/pull/98)
* Add `LICENSE` file [#100](https://github.com/hashicorp/terraform-enterprise-helm/pull/100)
* Bump appVersion to `v202410-1` [#92](https://github.com/hashicorp/terraform-enterprise-helm/pull/92)

## v1.3.3 (October 22nd, 2024)
TFE application version: `v202410-1`
* Fix deployment to use overridden `serviceAccount.name` when a custom service account name is specified [#93](https://github.com/hashicorp/terraform-enterprise-helm/pull/93)
* Add `serviceAccount.name` value — allows specifying a custom Service Account name instead of defaulting to the release namespace [#91](https://github.com/hashicorp/terraform-enterprise-helm/pull/91)

## v1.3.2 (September 6th, 2024)
TFE application version: `v202408-1`
* Add `pod.labels` value — allows setting additional pod labels on the TFE deployment pod template [#79](https://github.com/hashicorp/terraform-enterprise-helm/pull/79)

## v1.3.1 (August 26th, 2024)
TFE application version: `v202408-1`
* Add `strategy` value — allows configuring the Deployment's update strategy (e.g. `RollingUpdate` with `maxSurge`/`maxUnavailable`) [#87](https://github.com/hashicorp/terraform-enterprise-helm/pull/87)
* Add `appProtocol: https` to the Service's HTTPS port [#77](https://github.com/hashicorp/terraform-enterprise-helm/pull/77)
* Add `deployment.labels` and `deployment.annotations` values for metadata on the Deployment object [#79](https://github.com/hashicorp/terraform-enterprise-helm/pull/79)

## v1.3.0 (July 26th, 2024)
TFE application version: `v202407-1`
* Add OpenShift support — new `openshift.enabled` value; automatically injects a hardened `securityContext` (seccompProfile, allowPrivilegeEscalation, capabilities) for both the TFE container and agent worker pods when enabled [#71](https://github.com/hashicorp/terraform-enterprise-helm/pull/71)
* Add `topologySpreadConstraints` value — supports Kubernetes `PodSpec.topologySpreadConstraints` for zone-aware pod scheduling [#62](https://github.com/hashicorp/terraform-enterprise-helm/pull/62)
* Add configmap and secret checksum annotations to the pod template to trigger automatic rolling restarts on config changes [#63](https://github.com/hashicorp/terraform-enterprise-helm/pull/63)
* Separate `serviceAccount` and agent RBAC into dedicated templates (`service-account.yaml`, `agents-namespace.yaml`); add `serviceAccount.enabled` and `serviceAccount.labels` toggles [#64](https://github.com/hashicorp/terraform-enterprise-helm/pull/64)
* Add `agents.rbac.enabled/annotations/labels` and `agents.namespace.enabled/annotations/labels` values for fine-grained control of agent RBAC and namespace resources [#64](https://github.com/hashicorp/terraform-enterprise-helm/pull/64)
* Add `service.loadBalancerIP` value — optionally pins the LoadBalancer service to a specific external IP [#68](https://github.com/hashicorp/terraform-enterprise-helm/pull/68)
* Set minimum `appVersion` constraint in `Chart.yaml` [#80](https://github.com/hashicorp/terraform-enterprise-helm/pull/80)
* Add forking support statement to README [#69](https://github.com/hashicorp/terraform-enterprise-helm/pull/69)

## v1.2.0 (April 25th, 2024)
TFE application version: `v202404-1`
* Add `agentWorkerPodTemplate` value — allows providing a custom `corev1.PodTemplateSpec` for agent worker pods; the value is JSON-encoded and base64-encoded into `TFE_RUN_PIPELINE_KUBERNETES_POD_TEMPLATE` [#65](https://github.com/hashicorp/terraform-enterprise-helm/pull/65)
* Add support for configurable pod template via `pod.annotations` nindent fix [#46](https://github.com/hashicorp/terraform-enterprise-helm/pull/46)
* Allow `agentWorkerPodTemplate` to be specified in YAML format [#66](https://github.com/hashicorp/terraform-enterprise-helm/pull/66)

## 1.1.1 (December 5th, 2023)
* Support container `securityContext` configuration from values [#57](https://github.com/hashicorp/terraform-enterprise-helm/pull/57)

## 1.1.0 (November 2nd, 2023)
* Support annotations on the service account [#45](https://github.com/hashicorp/terraform-enterprise-helm/pull/45)

## 1.0.0 GA (September 18th, 2023)
This release does not contain any chart changes.

The README has been updated for Terraform Enterprise Flexible Deployment Options General Availability in [v202309-1](https://developer.hashicorp.com/terraform/enterprise/releases/2023/v202309-1).

## 0.1.2 (July 18th, 2023)
* Fix an issue where providing `.Values.environment.configMapRefs` was overwriting a required configMap in the Terraform Enterprise deployment

## 0.1.1 (July 13th, 2023)
Development

## 0.1.0 (April 6th, 2023)
Initial release
