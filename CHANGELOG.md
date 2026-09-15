# Changelog

## v2.0.x

Compatible with TFE `2.0.4`

### [v2.0.4] — 2026-07-17

**appVersion:** `2.0.4`

#### Features

- Add configurable readiness probe timing via `tfe.readinessProbeInitialDelaySeconds`, `tfe.readinessProbePeriodSeconds`, `tfe.readinessProbeFailureThreshold`, and `tfe.readinessProbeTimeoutSeconds` [#208](https://github.com/hashicorp/terraform-enterprise-helm/pull/208)

#### CI / Internal

- Add pre-upgrade validation GitHub Actions workflow [#163](https://github.com/hashicorp/terraform-enterprise-helm/pull/163)
- Improve pre-upgrade and upgrade runbooks based on feedback [#168](https://github.com/hashicorp/terraform-enterprise-helm/pull/168) [#166](https://github.com/hashicorp/terraform-enterprise-helm/pull/166)


**Full diff:** [`v1.6.8...v2.0.4`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.6.8...v2.0.4)

---

## v1.6.x

### [v1.6.10] — 2026-07-06

**appVersion:** `1.2.4`

Compatible with TFE `1.2.4`.

#### CI / Internal

- Bump chart version to trigger Helm index update for TFE `1.2.4` release [#202](https://github.com/hashicorp/terraform-enterprise-helm/pull/202) [#201](https://github.com/hashicorp/terraform-enterprise-helm/pull/201)
- Bump appVersion to `1.2.4`

**Full diff:** [`v1.6.7...v1.6.10`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.6.7...v1.6.10)

---

### [v1.6.8] — 2026-06-25

**appVersion:** `2.0.3` 

Compatible with TFE `2.0.0`–`2.0.3`

#### Features

- Add `tfe.adminHttpsPort` value (default `8446`) and expose it as a container port and Service port (`admin-https-port`) [#135](https://github.com/hashicorp/terraform-enterprise-helm/pull/135) [#137](https://github.com/hashicorp/terraform-enterprise-helm/pull/137)

#### CI / Internal

- Bump appVersion to `1.2.3` / `2.0.x` stream

**Full diff:** [`v1.6.6...v1.6.8`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.6.6...v1.6.8)

---

### [v1.6.7] — 2026-05-05

**appVersion:** `1.2.3`

Compatible with TFE `1.2.0`–`1.2.3`.

#### CI / Internal

- Bump appVersion to `1.2.3` [#175](https://github.com/hashicorp/terraform-enterprise-helm/pull/175) [#159](https://github.com/hashicorp/terraform-enterprise-helm/pull/159)

**Full diff:** [`v1.6.6...v1.6.7`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.6.6...v1.6.7)

---

### [v1.6.6] — 2026-01-19

**appVersion:** `1.1.4`

Compatible with TFE `1.1.0`–`1.1.4`.

#### Features

- Add mTLS support for Redis and Redis Enterprise — new `tfe.redis.tls.*` and `tfe.redis.sidekiq.tls.*` value blocks mount client certificate/key and CA cert as a secret, and expose matching `TFE_REDIS_*_TLS_*` env vars in the ConfigMap [#140](https://github.com/hashicorp/terraform-enterprise-helm/pull/140)
- Add `deployment.labels` and `deployment.annotations` values for metadata on the Deployment object [#142](https://github.com/hashicorp/terraform-enterprise-helm/pull/142)
- Update readiness probe default path from `/_health_check` to `/api/v1/health/readiness` [#157](https://github.com/hashicorp/terraform-enterprise-helm/pull/157)
- Removed `TFE_RUN_PIPELINE_KUBERNETES_OPEN_SHIFT_ENABLED` environment variable [#139](https://github.com/hashicorp/terraform-enterprise-helm/pull/139)

#### Documentation

- Clarify Redis mTLS support documentation to specify "Redis Standalone" alongside "Redis Enterprise" [#140](https://github.com/hashicorp/terraform-enterprise-helm/pull/140)

#### CI / Internal

- Update MinIO dependency to version `5.4.0` / image tag `RELEASE.2025-10-15T17-29-55Z` [#153](https://github.com/hashicorp/terraform-enterprise-helm/pull/153)
- Add automated tag-and-release workflow [#152](https://github.com/hashicorp/terraform-enterprise-helm/pull/152) [#150](https://github.com/hashicorp/terraform-enterprise-helm/pull/150)
- Add compliance copyright and license headers (Batch 1) [#149](https://github.com/hashicorp/terraform-enterprise-helm/pull/149)
- Remove Jira issue creation workflow [#145](https://github.com/hashicorp/terraform-enterprise-helm/pull/145)
- Bump appVersion through `1.1.0` → `1.1.2` → `1.1.3` → `1.1.4`

**Full diff:** [`v1.6.5...v1.6.6`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.6.5...v1.6.6)

---

### [v1.6.5] — 2025-08-12

**appVersion:** `1.0.0`

Compatible with TFE `v202507-1` and `1.0.0`–`1.0.3`.

#### Features

- Add `tlsSecondary.certificateSecret` support — allows referencing a pre-existing Kubernetes secret for the secondary hostname certificate instead of providing raw cert data [#138](https://github.com/hashicorp/terraform-enterprise-helm/pull/138)
- Add configurable secondary hostname (`tlsSecondary`) TLS support with `certMountPath` / `keyMountPath` [#138](https://github.com/hashicorp/terraform-enterprise-helm/pull/138)
- Increase default resource requests to `8192Mi` memory / `4000m` CPU [#133](https://github.com/hashicorp/terraform-enterprise-helm/pull/133)
- Remove `env.configFilePath` and `env.secretsFilePath` file-based config options [#120](https://github.com/hashicorp/terraform-enterprise-helm/pull/120)

#### CI / Internal

- Bump appVersion to `1.0.0`

**Full diff:** [`v1.6.4...v1.6.5`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.6.4...v1.6.5)

---

### [v1.6.4] — 2025-07-14

**appVersion:** `v202507-1`

#### Features

- Add `agents.namespace.name` value — allows overriding the agent namespace name (defaults to `<release-namespace>-agents`) [#134](https://github.com/hashicorp/terraform-enterprise-helm/pull/134)
- Fix readiness probe to respect `tfe.readinessProbePath` and `tfe.readinessProbeScheme` values (previously hardcoded) [#134](https://github.com/hashicorp/terraform-enterprise-helm/pull/134)
- Replace hardcoded `appProtocol: https` service value with configurable `service.appProtocol` (defaults to `tcp`) [#134](https://github.com/hashicorp/terraform-enterprise-helm/pull/134)

#### CI / Internal

- Bump appVersion to `v202507-1`

**Full diff:** [`v1.6.3...v1.6.4`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.6.3...v1.6.4)

---

### [v1.6.3] — 2025-06-10

**appVersion:** `v202506-1`

Compatible with TFE `v202506-1`.

#### CI / Internal

- Bump appVersion to `v202506-1` [#132](https://github.com/hashicorp/terraform-enterprise-helm/pull/132)

**Full diff:** [`v1.6.2...v1.6.3`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.6.2...v1.6.3)

---

### [v1.6.2] — 2025-05-30

**appVersion:** `v202505-1`

Compatible with TFE `v202505-1`.

#### CI / Internal

- Fix chart version — corrected version numbering after an accidental `1.7.0` bump [#131](https://github.com/hashicorp/terraform-enterprise-helm/pull/131)
- Bump appVersion to `v202505-1` [#126](https://github.com/hashicorp/terraform-enterprise-helm/pull/126)

**Full diff:** [`v1.6.1...v1.6.2`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.6.1...v1.6.2)

---

### [v1.6.1] — 2025-04-22

**appVersion:** `v202504-1`

Compatible with TFE `v202504-1`.

#### CI / Internal

- Remove SOX check workflow
- Bump appVersion to `v202504-1` [#124](https://github.com/hashicorp/terraform-enterprise-helm/pull/124)

**Full diff:** [`v1.6.0...v1.6.1`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.6.0...v1.6.1)

---

### [v1.6.0] — 2025-03-17

**appVersion:** `v202503-1`

Compatible with TFE `v202503-1` and up.

#### Features

- Integrate Secrets Store CSI Driver (Vault provider) as a secrets source option — new `csi.*` values block adds a `SecretProviderClass` template and mounts the CSI volume into the TFE container [#118](https://github.com/hashicorp/terraform-enterprise-helm/pull/118)
- Support `env.secretKeyRefs` and `env.configMapKeyRefs` to inject external Kubernetes secrets and ConfigMap entries as individual environment variables via `valueFrom` [#111](https://github.com/hashicorp/terraform-enterprise-helm/pull/111)

#### CI / Internal

- Add compliance copyright and license headers to all templates [#122](https://github.com/hashicorp/terraform-enterprise-helm/pull/122)
- Bump appVersion to `v202503-1`

**Full diff:** [`v1.5.0...v1.6.0`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.5.0...v1.6.0)

---

## v1.5.x

### [v1.5.0] — 2025-02-20

**appVersion:** `v202502-1`

Compatible with TFE `v202502-1` and up.

#### Features

- Add `pdb` values block — optionally creates a `PodDisruptionBudget` for the TFE deployment (`pdb.enabled`, `pdb.replicaCount`, `pdb.annotations`, `pdb.labels`) [#115](https://github.com/hashicorp/terraform-enterprise-helm/pull/115)
- Add `extraVolumes` and `extraVolumeMounts` values — allows attaching arbitrary volumes (e.g. cert-manager secrets, PVCs for persistent logs) to the TFE pod [#112](https://github.com/hashicorp/terraform-enterprise-helm/pull/112)
- Add `service.labels` value — adds labels to the TFE Service [#109](https://github.com/hashicorp/terraform-enterprise-helm/pull/109)
- Fix RBAC `RoleBinding` subject name to use `serviceAccount.name` when a custom service account name is provided [#108](https://github.com/hashicorp/terraform-enterprise-helm/pull/108)

#### CI / Internal

- Bump appVersion to `v202502-1`

**Full diff:** [`v1.4.0...v1.5.0`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.4.0...v1.5.0)

---

## v1.4.x

### [v1.4.0] — 2025-01-16

**appVersion:** `v202501-1`

Compatible with TFE `v202501-1` and up.

#### Features

- Add `extraVolumes` and `extraVolumeMounts` values to attach arbitrary volumes to the TFE pod [#112](https://github.com/hashicorp/terraform-enterprise-helm/pull/112)
- Add optional `service.labels` to the TFE Service [#109](https://github.com/hashicorp/terraform-enterprise-helm/pull/109)
- Fix RBAC `RoleBinding` subject name to use `serviceAccount.name` when a custom service account name is provided [#108](https://github.com/hashicorp/terraform-enterprise-helm/pull/108)

#### CI / Internal

- Bump appVersion to `v202501-1`

**Full diff:** [`v1.3.4...v1.4.0`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.3.4...v1.4.0)

---

## v1.3.x

### [v1.3.4] — 2024-11-26

**appVersion:** `v202411-1`

Compatible with TFE `v202411-1`.

#### Features

- Add optional readiness probe path and scheme configuration (`tfe.readinessProbePath`, `tfe.readinessProbeScheme`) [#95](https://github.com/hashicorp/terraform-enterprise-helm/pull/95)
- Fix `readinessProbePath` and `readinessProbeScheme` not being applied when values are unset — now correctly falls back to `/_health_check` and `HTTP` [#101](https://github.com/hashicorp/terraform-enterprise-helm/pull/101)
- Add configurable `appProtocol` per Service port, replacing the previous hardcoded `https` value; add Azure `appProtocol: tcp` guidance in `values.yaml` [#103](https://github.com/hashicorp/terraform-enterprise-helm/pull/103)
- Allow customizing the agent namespace name via `agents.namespace.name` [#96](https://github.com/hashicorp/terraform-enterprise-helm/pull/96)

#### Documentation

- Document `TFE_REDIS_SIDEKIQ_*` example configuration in `values.yaml` [#98](https://github.com/hashicorp/terraform-enterprise-helm/pull/98)
- Add `LICENSE` file [#100](https://github.com/hashicorp/terraform-enterprise-helm/pull/100)

#### CI / Internal

- Add CI linting via `kubeconform` to prevent merging invalid manifests [#102](https://github.com/hashicorp/terraform-enterprise-helm/pull/102)
- Bump appVersion to `v202411-1`

**Full diff:** [`v1.3.3...v1.3.4`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.3.3...v1.3.4)

---

### [v1.3.3] — 2024-10-22

**appVersion:** `v202410-1`

Compatible with TFE `v202410-1`.

#### Features

- Add `serviceAccount.name` value — allows specifying a custom Service Account name instead of defaulting to the release namespace [#91](https://github.com/hashicorp/terraform-enterprise-helm/pull/91)
- Fix Deployment to use overridden `serviceAccount.name` when a custom name is specified [#93](https://github.com/hashicorp/terraform-enterprise-helm/pull/93)

#### CI / Internal

- Bump appVersion to `v202410-1`

**Full diff:** [`v1.3.2...v1.3.3`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.3.2...v1.3.3)

---

### [v1.3.2] — 2024-09-06

**appVersion:** `v202409-1`

Compatible with TFE `v202409-1`.

#### Features

- Add `pod.labels` value — allows setting additional labels on the TFE deployment pod template [#79](https://github.com/hashicorp/terraform-enterprise-helm/pull/79)

#### CI / Internal

- Bump appVersion to `v202409-1`

**Full diff:** [`v1.3.1...v1.3.2`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.3.1...v1.3.2)

---

### [v1.3.1] — 2024-08-26

**appVersion:** `v202408-1`

Compatible with TFE `v202408-1`.

#### Features

- Add `strategy` value — allows configuring the Deployment's update strategy (e.g. `RollingUpdate` with `maxSurge` / `maxUnavailable`) [#87](https://github.com/hashicorp/terraform-enterprise-helm/pull/87)
- Add `appProtocol: https` to the Service's HTTPS port [#77](https://github.com/hashicorp/terraform-enterprise-helm/pull/77)
- Add `deployment.labels` and `deployment.annotations` values for metadata on the Deployment object [#79](https://github.com/hashicorp/terraform-enterprise-helm/pull/79)

#### CI / Internal

- Bump appVersion to `v202408-1`

**Full diff:** [`v1.3.0...v1.3.1`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.3.0...v1.3.1)

---

### [v1.3.0] — 2024-07-26

**appVersion:** `v202406-1`

Compatible with TFE `v202406-1` and up.

#### Features

- Add OpenShift support — new `openshift.enabled` value; automatically injects a hardened `securityContext` for both the TFE container and agent worker pods when enabled [#71](https://github.com/hashicorp/terraform-enterprise-helm/pull/71)
- Add `topologySpreadConstraints` value — supports Kubernetes `PodSpec.topologySpreadConstraints` for zone-aware pod scheduling [#62](https://github.com/hashicorp/terraform-enterprise-helm/pull/62)
- Add ConfigMap and Secret checksum annotations to the pod template to trigger automatic rolling restarts on config changes [#63](https://github.com/hashicorp/terraform-enterprise-helm/pull/63)
- Separate `serviceAccount` and agent RBAC into dedicated templates (`service-account.yaml`, `agents-namespace.yaml`); add `serviceAccount.enabled` and `serviceAccount.labels` toggles [#64](https://github.com/hashicorp/terraform-enterprise-helm/pull/64)
- Add `agents.rbac.enabled/annotations/labels` and `agents.namespace.enabled/annotations/labels` values for fine-grained control of agent RBAC and namespace resources [#64](https://github.com/hashicorp/terraform-enterprise-helm/pull/64)
- Add `service.loadBalancerIP` value — optionally pins the LoadBalancer Service to a specific external IP [#68](https://github.com/hashicorp/terraform-enterprise-helm/pull/68)
- Set minimum `appVersion` constraint in `Chart.yaml`

#### Documentation

- Add forking support statement to README [#69](https://github.com/hashicorp/terraform-enterprise-helm/pull/69)

#### CI / Internal

- Bump appVersion to `v202406-1`

**Full diff:** [`v1.2.0...v1.3.0`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.2.0...v1.3.0)

---

## v1.2.x

### [v1.2.0] — 2024-04-25

**appVersion:** `v202404-1`

Compatible with TFE `v202404-1` and up.

#### Features

- Add `agentWorkerPodTemplate` value — allows providing a custom `corev1.PodTemplateSpec` for agent worker pods; the value is JSON-encoded and base64-encoded into `TFE_RUN_PIPELINE_KUBERNETES_POD_TEMPLATE` [#65](https://github.com/hashicorp/terraform-enterprise-helm/pull/65)
- Allow `agentWorkerPodTemplate` to be specified in YAML format [#66](https://github.com/hashicorp/terraform-enterprise-helm/pull/66)
- Fix incorrect `pod.annotations` indentation in the pod template [#46](https://github.com/hashicorp/terraform-enterprise-helm/pull/46)
- Fix container image name reference [#61](https://github.com/hashicorp/terraform-enterprise-helm/pull/61)

#### CI / Internal

- Bump appVersion to `v202404-1`

**Full diff:** [`v1.1.1...v1.2.0`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.1.1...v1.2.0)

---

## v1.1.x

### [v1.1.1] — 2023-12-05

**appVersion:** `1.16.0`

Compatible with TFE `v202312-1` and up.

#### Features

- Support container `securityContext` configuration from values [#57](https://github.com/hashicorp/terraform-enterprise-helm/pull/57)

**Full diff:** [`v1.1.0...v1.1.1`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.1.0...v1.1.1)

---

### [v1.1.0] — 2023-11-02

**appVersion:** `1.16.0`

Compatible with TFE `v202311-1` and up.

#### Features

- Support annotations on the Service Account [#45](https://github.com/hashicorp/terraform-enterprise-helm/pull/45)
- Add IACT (Initial Admin Creation Token) variables [#43](https://github.com/hashicorp/terraform-enterprise-helm/pull/43)
- Inject namespace into all resources that were previously missing it [#42](https://github.com/hashicorp/terraform-enterprise-helm/pull/42)

#### CI / Internal

- Add GitHub Actions workflow for Jira issue creation [#47](https://github.com/hashicorp/terraform-enterprise-helm/pull/47)

**Full diff:** [`v1.0.0...v1.1.0`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.0.0...v1.1.0)

---

## v1.0.x

### [v1.0.0] — 2023-09-18

**appVersion:** `1.16.0`

General Availability release. Compatible with TFE Flexible Deployment Options `v202309-1` and up.

#### Features

- Add TFE metrics configuration support [#37](https://github.com/hashicorp/terraform-enterprise-helm/pull/37)
- Add debug mode configuration [#35](https://github.com/hashicorp/terraform-enterprise-helm/pull/35)

#### Documentation

- Update documentation for Terraform Enterprise Flexible Deployment Options General Availability (`v202309-1`) [#41](https://github.com/hashicorp/terraform-enterprise-helm/pull/41)
- Update Helm variable documentation [#39](https://github.com/hashicorp/terraform-enterprise-helm/pull/39)
- Update registry address to point to the official registry; generalize image tag references [#38](https://github.com/hashicorp/terraform-enterprise-helm/pull/38)

#### CI / Internal

- Add compliance copyright and license headers [#30](https://github.com/hashicorp/terraform-enterprise-helm/pull/30)
- Add Helm chart update workflow [#28](https://github.com/hashicorp/terraform-enterprise-helm/pull/28)

**Full diff:** [`v0.1.2...v1.0.0`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v0.1.2...v1.0.0)

---

## v0.1.x

Initial development releases.

### [v0.1.2] — 2023-07-18

**appVersion:** `1.16.0`

#### Features

- Fix default env config injection — providing `.Values.environment.configMapRefs` no longer overwrites the required built-in ConfigMap in the TFE Deployment [#33](https://github.com/hashicorp/terraform-enterprise-helm/pull/33)

**Full diff:** [`v0.1.1...v0.1.2`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v0.1.1...v0.1.2)

---

### [v0.1.1] — 2023-07-13

**appVersion:** `1.16.0`

#### CI / Internal

- Increment chart patch version in preparation for release [#31](https://github.com/hashicorp/terraform-enterprise-helm/pull/31)

**Full diff:** [`v0.1.0...v0.1.1`](https://github.com/hashicorp/terraform-enterprise-helm/compare/v0.1.0...v0.1.1)

---

### [v0.1.0] — 2023-07-13

**appVersion:** `1.16.0`

#### Features

- Initial release
- Add `envFrom` entries support [#23](https://github.com/hashicorp/terraform-enterprise-helm/pull/23)
- Trim strings before base64 encoding [#25](https://github.com/hashicorp/terraform-enterprise-helm/pull/25)
- Add license env variable [#26](https://github.com/hashicorp/terraform-enterprise-helm/pull/26)
- Remove default `configFilePath` [#27](https://github.com/hashicorp/terraform-enterprise-helm/pull/27)

#### Documentation

- Prefer the public registry in examples and documentation [#29](https://github.com/hashicorp/terraform-enterprise-helm/pull/29)
