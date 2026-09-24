# Changelog

Notable user-facing changes to this chart are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Chart versions use [Semantic Versioning](https://semver.org/spec/v2.0.0.html)-compatible
version numbers.

Dates are GitHub Release publication dates in UTC. When a historical GitHub
Release or tag no longer identifies the published chart, the date is from the
HashiCorp Helm repository.

`appVersion` records the Terraform Enterprise application release associated
with the chart. It is informational and does not define a compatibility range.

## Unreleased

## 2.0.8 - 2026-09-23

**Terraform Enterprise appVersion:** `2.0.8`

No user-facing chart changes.

## 2.0.7 - 2026-09-15

**Terraform Enterprise appVersion:** `2.0.7`

No user-facing chart changes.

The chart package exists at its direct URL but is absent from the current
HashiCorp Helm repository index.

## 2.0.6 - 2026-08-31

**Terraform Enterprise appVersion:** `2.0.6`

No user-facing chart changes.

## 2.0.5 - 2026-08-05

**Terraform Enterprise appVersion:** `2.0.5`

No user-facing chart changes.

## 2.0.4 - 2026-07-17

**Terraform Enterprise appVersion:** `2.0.4`

### Added

- Added configurable readiness probe timing through
  `tfe.readinessProbeInitialDelaySeconds`, `tfe.readinessProbePeriodSeconds`,
  `tfe.readinessProbeFailureThreshold`, and
  `tfe.readinessProbeTimeoutSeconds`.

## 1.6.10 - 2026-07-06

**Terraform Enterprise appVersion:** `1.2.4`

This package was released from the parallel Terraform Enterprise 1.2.x release
branch.

No user-facing chart changes.

## 1.6.9 - 2026-06-25

**Terraform Enterprise appVersion:** `2.0.4`

The date is from the HashiCorp Helm repository. The published package has no
corresponding GitHub Release or current `v1.6.9` tag.

No user-facing chart changes.

## 1.6.8 - 2026-05-15

**Terraform Enterprise appVersion:** `2.0.2`

The date is from the HashiCorp Helm repository because the current `v1.6.8`
tag was moved after this package was published.

### Added

- Added a pre-upgrade validation mode, including a validation Job, an optional
  override Secret, configuration validation, and minimal-prerequisite
  rendering.
- Added an upgrade and rollback guide and documented the pre-upgrade validation
  workflow.

### Changed

- Improved pre-upgrade validation volume handling and operational guidance based
  on release feedback.

## 1.6.7 - 2026-05-06

**Terraform Enterprise appVersion:** `1.2.3`

The date is from the HashiCorp Helm repository because the GitHub Release
retains the publication timestamp of an earlier `1.6.7` artifact.

### Changed

- Changed the default readiness probe path from `/_health_check` to
  `/api/v1/health/readiness`.

## 1.6.6 - 2025-12-11

**Terraform Enterprise appVersion:** `1.1.2`

The date is from the HashiCorp Helm repository because the current `v1.6.6`
tag was moved after this package was published.

### Added

- Added Redis and Redis Enterprise mTLS configuration through the `tlsRedis`
  and `tlsRedisSidekiq` value blocks.
- Added `deployment.labels` and `deployment.annotations` values.

### Removed

- Removed the obsolete
  `TFE_RUN_PIPELINE_KUBERNETES_OPEN_SHIFT_ENABLED` environment variable while
  retaining `openshift.enabled` for chart-managed security contexts.

## 1.6.5 - 2025-08-13

**Terraform Enterprise appVersion:** `1.0.0`

### Added

- Added `tfe.adminHttpsPort`, defaulting to `8446`, and exposed the admin HTTPS
  port through the container and Services.

## 1.6.4 - 2025-07-14

**Terraform Enterprise appVersion:** `v202507-1`

### Added

- Added secondary hostname support, including secondary TLS configuration and
  an optional secondary Service.
- Added support for referencing an existing secondary TLS certificate Secret
  through `tlsSecondary.certificateSecret`.

### Changed

- Increased default resource requests to `8192Mi` memory and `4000m` CPU.

### Removed

- Removed the file-based `env.configFilePath` and `env.secretsFilePath`
  options.

## 1.6.3 - 2025-06-16

**Terraform Enterprise appVersion:** `v202506-1`

No user-facing chart changes.

## 1.6.2 - 2025-05-30

**Terraform Enterprise appVersion:** `v202505-1`

No user-facing chart changes.

## 1.6.1 - 2025-04-22

**Terraform Enterprise appVersion:** `v202504-1`

No user-facing chart changes.

## 1.6.0 - 2025-03-19

**Terraform Enterprise appVersion:** `v202503-1`

### Added

- Added Secrets Store CSI Driver integration with the Vault provider through
  the `csi.*` values, a `SecretProviderClass`, and a CSI volume mounted in the
  Terraform Enterprise container, with optional synchronization into Kubernetes
  Secrets through `csi.secretObjects`.
- Added `env.secretKeyRefs` and `env.configMapKeyRefs` for injecting individual
  environment variables from external Secrets and ConfigMaps.

## 1.5.0 - 2025-02-20

**Terraform Enterprise appVersion:** `v202502-1`

### Added

- Added optional PodDisruptionBudget creation through `pdb.enabled`,
  `pdb.replicaCount`, `pdb.annotations`, and `pdb.labels`.

## 1.4.0 - 2025-01-21

**Terraform Enterprise appVersion:** `v202501-1`

### Added

- Added `extraVolumes` and `extraVolumeMounts` for attaching arbitrary volumes
  to the Terraform Enterprise pod.
- Added `service.labels` for applying labels to the Terraform Enterprise
  Service.

### Fixed

- Fixed the RoleBinding subject to use `serviceAccount.name` when configured.

## 1.3.4 - 2024-11-26

**Terraform Enterprise appVersion:** `v202411-1`

### Added

- Added optional readiness probe path and scheme configuration through
  `tfe.readinessProbePath` and `tfe.readinessProbeScheme`.
- Added `agents.namespace.name` for selecting or creating a custom agent
  namespace.
- Added configuration examples for a separate Sidekiq Redis instance through
  the `TFE_REDIS_SIDEKIQ_*` environment variables.

### Changed

- Made `service.appProtocol` configurable, changed its default from `https` to
  `tcp` to restore Azure compatibility, and documented the Azure health probe
  annotation.

### Fixed

- Fixed chart rendering when readiness probe values are omitted by defaulting
  the path to `/_health_check` and the scheme to `HTTP`.
- Updated `docs/example/override.yaml` to include `TFE_LICENSE` and place
  `TFE_DATABASE_PASSWORD` and `TFE_ENCRYPTION_PASSWORD` under `env.secrets`.

## 1.3.3 - 2024-10-23

**Terraform Enterprise appVersion:** `v202410-1`

### Added

- Added `serviceAccount.name` for configuring a custom ServiceAccount name.

### Fixed

- Updated the Deployment to use the configured `serviceAccount.name`.

## 1.3.2 - 2024-09-12

**Terraform Enterprise appVersion:** `v202409-1`

### Added

- Added `pod.labels` for setting labels on the Deployment pod template.

## 1.3.1 - 2024-08-26

**Terraform Enterprise appVersion:** `v202408-1`

### Added

- Added configurable Kubernetes Deployment strategy support through `strategy`.
- Added `appProtocol: https` to the Service HTTPS port.

## 1.3.0 - 2024-07-29

**Terraform Enterprise appVersion:** `v202406-1`

### Added

- Added OpenShift support through `openshift.enabled`, including default
  security contexts and the
  `TFE_RUN_PIPELINE_KUBERNETES_OPEN_SHIFT_ENABLED` environment variable.
- Added `topologySpreadConstraints` for topology-aware pod scheduling.
- Added ConfigMap and Secret checksum annotations to trigger rolling restarts
  when configuration changes.
- Added `serviceAccount.enabled` and `serviceAccount.labels` and moved the
  ServiceAccount and agent Namespace resources into dedicated templates.
- Added `agents.rbac.enabled`, `agents.rbac.annotations`, `agents.rbac.labels`,
  `agents.namespace.enabled`, `agents.namespace.annotations`, and
  `agents.namespace.labels` for controlling agent resources.
- Added `service.loadBalancerIP` for configuring a LoadBalancer Service IP.

## 1.2.0 - 2024-04-25

**Terraform Enterprise appVersion:** `1.16.0`

### Added

- Added `agentWorkerPodTemplate` for supplying a custom
  `corev1.PodTemplateSpec` for agent worker pods.
- Added support for specifying `agentWorkerPodTemplate` in YAML format.

### Fixed

- Fixed `pod.annotations` indentation in the pod template.
- Fixed the Terraform Enterprise image name in `docs/example/override.yaml`.

## 1.1.1 - 2023-12-05

**Terraform Enterprise appVersion:** `1.16.0`

### Added

- Added container `securityContext` configuration through chart values.

## 1.1.0 - 2023-11-02

**Terraform Enterprise appVersion:** `1.16.0`

### Added

- Added annotations to the chart-managed ServiceAccount.
- Added configuration examples for `TFE_IACT_SUBNETS` and
  `TFE_IACT_TIME_LIMIT`.

### Fixed

- Added missing Namespace metadata to the Deployment, Ingress, and Service, and
  corrected the default Terraform Enterprise image name.

## 1.0.0 - 2023-09-18

**Terraform Enterprise appVersion:** `1.16.0`

This release marked General Availability for Terraform Enterprise Flexible
Deployment Options. The entries below summarize notable changes accumulated in
the `v0.1.2...v1.0.0` source diff.

### Added

- Added configuration examples for
  `TFE_RUN_PIPELINE_KUBERNETES_DEBUG_ENABLED` and
  `TFE_RUN_PIPELINE_KUBERNETES_DEBUG_JOBS_TTL`.
- Added Terraform Enterprise metrics configuration and ports.

### Changed

- Reduced default resource requests from `5000Mi` memory and `4` CPU to
  `2500Mi` memory and `750m` CPU.
- Updated documentation and examples for the General Availability active-active
  architecture, including the official image registry and Redis prerequisite.

## 0.1.2 - 2023-07-18

**Terraform Enterprise appVersion:** `1.16.0`

### Fixed

- Ensured the built-in ConfigMap and Secret remain in `envFrom` when
  `.Values.env.configMapRefs` or `.Values.env.secretRefs` are supplied.

## 0.1.1 - 2023-07-14

**Terraform Enterprise appVersion:** `1.16.0`

This was the first chart version published in the HashiCorp Helm repository.

## 0.1.0 - 2023-07-13

**Terraform Enterprise appVersion:** `1.16.0`

This was the initial tagged development release. No `0.1.0` package is present
in the HashiCorp Helm repository.

### Added

- Added the initial Terraform Enterprise Helm chart.
