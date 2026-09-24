# Changelog

All notable changes to this chart are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Chart versions follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

Dates are GitHub Release publication dates in UTC. When a historical GitHub
Release or tag no longer identifies the published chart, the date is from the
HashiCorp Helm repository and the entry links immutable source commits.

`appVersion` records the Terraform Enterprise application release associated
with the chart. It is informational and does not define a compatibility range.

## [Unreleased]

## [2.0.7] - 2026-09-15

**Terraform Enterprise appVersion:** `2.0.7`

No user-facing chart changes.

## [2.0.6] - 2026-08-31

**Terraform Enterprise appVersion:** `2.0.6`

No user-facing chart changes.

## [2.0.5] - 2026-08-05

**Terraform Enterprise appVersion:** `2.0.5`

No user-facing chart changes.

## [2.0.4] - 2026-07-17

**Terraform Enterprise appVersion:** `2.0.4`

### Added

- Added configurable readiness probe timing through
  `tfe.readinessProbeInitialDelaySeconds`, `tfe.readinessProbePeriodSeconds`,
  `tfe.readinessProbeFailureThreshold`, and
  `tfe.readinessProbeTimeoutSeconds` [#208].

## [1.6.10] - 2026-07-06

**Terraform Enterprise appVersion:** `1.2.4`

This package was released from the parallel Terraform Enterprise 1.2.x release
branch.

No user-facing chart changes.

## [1.6.9] - 2026-06-25

**Terraform Enterprise appVersion:** `2.0.4`

The date is from the HashiCorp Helm repository. The published package has no
corresponding GitHub Release or current `v1.6.9` tag.

No user-facing chart changes.

## [1.6.8] - 2026-05-15

**Terraform Enterprise appVersion:** `2.0.2`

The date is from the HashiCorp Helm repository because the current `v1.6.8`
tag was moved after this package was published.

### Added

- Added a pre-upgrade validation mode, including a validation Job, an optional
  override Secret, configuration validation, and minimal-prerequisite
  rendering [#163].
- Added an upgrade and rollback guide and documented the pre-upgrade validation
  workflow [#163] [#166].

### Changed

- Improved pre-upgrade validation volume handling and operational guidance
  [#166].

## [1.6.7] - 2026-05-06

**Terraform Enterprise appVersion:** `1.2.3`

The date is from the HashiCorp Helm repository because the corresponding
GitHub tag and Release were moved after publication.

### Changed

- Changed the default readiness probe path from `/_health_check` to
  `/api/v1/health/readiness` [#157].

## [1.6.6] - 2025-12-11

**Terraform Enterprise appVersion:** `1.1.2`

The date is from the HashiCorp Helm repository because the current `v1.6.6`
tag was moved after this package was published.

### Added

- Added Redis and Redis Enterprise mTLS configuration through the `tlsRedis`
  and `tlsRedisSidekiq` value blocks [#140].
- Added `deployment.labels` and `deployment.annotations` values [#142].

### Removed

- Removed the obsolete
  `TFE_RUN_PIPELINE_KUBERNETES_OPEN_SHIFT_ENABLED` environment variable while
  retaining `openshift.enabled` for chart-managed security contexts [#139].

## [1.6.5] - 2025-08-13

**Terraform Enterprise appVersion:** `1.0.0`

### Added

- Added `tfe.adminHttpsPort`, defaulting to `8446`, and exposed the admin HTTPS
  port through the container and Services [#135] [#137].

## [1.6.4] - 2025-07-14

**Terraform Enterprise appVersion:** `v202507-1`

### Added

- Added secondary hostname support, including secondary TLS configuration and
  an optional secondary Service [#129].
- Added support for referencing an existing secondary TLS certificate Secret
  through `tlsSecondary.certificateSecret` [#129].

### Changed

- Increased default resource requests to `8192Mi` memory and `4000m` CPU
  [#133].

### Removed

- Removed the file-based `env.configFilePath` and `env.secretsFilePath`
  options [#120].

## [1.6.3] - 2025-06-16

**Terraform Enterprise appVersion:** `v202506-1`

No user-facing chart changes.

## [1.6.2] - 2025-05-30

**Terraform Enterprise appVersion:** `v202505-1`

No user-facing chart changes.

## [1.6.1] - 2025-04-22

**Terraform Enterprise appVersion:** `v202504-1`

No user-facing chart changes.

## [1.6.0] - 2025-03-19

**Terraform Enterprise appVersion:** `v202503-1`

### Added

- Added Secrets Store CSI Driver integration with the Vault provider through
  the `csi.*` values, a `SecretProviderClass`, and a CSI volume mounted in the
  Terraform Enterprise container [#118].
- Added `env.secretKeyRefs` and `env.configMapKeyRefs` for injecting individual
  environment variables from external Secrets and ConfigMaps [#111].

## [1.5.0] - 2025-02-20

**Terraform Enterprise appVersion:** `v202502-1`

### Added

- Added optional PodDisruptionBudget creation through `pdb.enabled`,
  `pdb.replicaCount`, `pdb.annotations`, and `pdb.labels` [#115].

## [1.4.0] - 2025-01-21

**Terraform Enterprise appVersion:** `v202501-1`

### Added

- Added `extraVolumes` and `extraVolumeMounts` for attaching arbitrary volumes
  to the Terraform Enterprise pod [#112].
- Added `service.labels` for applying labels to the Terraform Enterprise
  Service [#109].

### Fixed

- Fixed the RoleBinding subject to use `serviceAccount.name` when configured
  [#108].

## [1.3.4] - 2024-11-26

**Terraform Enterprise appVersion:** `v202411-1`

### Added

- Added optional readiness probe path and scheme configuration through
  `tfe.readinessProbePath` and `tfe.readinessProbeScheme` [#95].
- Added `agents.namespace.name` for selecting or creating a custom agent
  namespace [#96].
- Added configurable `service.appProtocol`, defaulting to `tcp`, and documented
  the Azure health probe annotation [#103].

### Fixed

- Fixed chart rendering when readiness probe values are omitted by defaulting
  the path to `/_health_check` and the scheme to `HTTP` [#101].

## [1.3.3] - 2024-10-23

**Terraform Enterprise appVersion:** `v202410-1`

### Added

- Added `serviceAccount.name` for configuring a custom ServiceAccount name
  [#91].

### Fixed

- Updated the Deployment to use the configured `serviceAccount.name` [#93].

## [1.3.2] - 2024-09-12

**Terraform Enterprise appVersion:** `v202409-1`

### Added

- Added `pod.labels` for setting labels on the Deployment pod template [#79].

## [1.3.1] - 2024-08-26

**Terraform Enterprise appVersion:** `v202408-1`

### Added

- Added configurable Kubernetes Deployment strategy support through `strategy`
  [#87].
- Added `appProtocol: https` to the Service HTTPS port [#77].

## [1.3.0] - 2024-07-29

**Terraform Enterprise appVersion:** `v202406-1`

### Added

- Added OpenShift support through `openshift.enabled`, including default
  security contexts and the
  `TFE_RUN_PIPELINE_KUBERNETES_OPEN_SHIFT_ENABLED` environment variable [#71].
- Added `topologySpreadConstraints` for topology-aware pod scheduling [#62].
- Added ConfigMap and Secret checksum annotations to trigger rolling restarts
  when configuration changes [#63].
- Added `serviceAccount.enabled` and `serviceAccount.labels` and moved the
  ServiceAccount and agent Namespace resources into dedicated templates [#64].
- Added `agents.rbac.enabled`, `agents.rbac.annotations`, `agents.rbac.labels`,
  `agents.namespace.enabled`, `agents.namespace.annotations`, and
  `agents.namespace.labels` for controlling agent resources [#64].
- Added `service.loadBalancerIP` for configuring a LoadBalancer Service IP
  [#68].

## [1.2.0] - 2024-04-25

**Terraform Enterprise appVersion:** `1.16.0`

### Added

- Added `agentWorkerPodTemplate` for supplying a custom
  `corev1.PodTemplateSpec` for agent worker pods [#65].
- Added support for specifying `agentWorkerPodTemplate` in YAML format [#66].

### Fixed

- Fixed `pod.annotations` indentation in the pod template [#46].
- Fixed the Terraform Enterprise image name in `docs/example/override.yaml`
  [#61].

## [1.1.1] - 2023-12-05

**Terraform Enterprise appVersion:** `1.16.0`

### Added

- Added container `securityContext` configuration through chart values [#57].

## [1.1.0] - 2023-11-02

**Terraform Enterprise appVersion:** `1.16.0`

### Added

- Added annotations to the chart-managed ServiceAccount [#45].

### Changed

- Added explicit Namespace metadata to namespaced resources and corrected the
  default Terraform Enterprise image name [#42].

## [1.0.0] - 2023-09-18

**Terraform Enterprise appVersion:** `1.16.0`

This release marked General Availability for Terraform Enterprise Flexible
Deployment Options. The entries below summarize notable changes accumulated in
the `v0.1.2...v1.0.0` source diff.

### Added

- Added Terraform Enterprise metrics configuration and ports [#37].

### Changed

- Reduced default resource requests from `5000Mi` memory and `4` CPU to
  `2500Mi` memory and `750m` CPU [#39].
- Updated documentation and examples for the General Availability active-active
  architecture, including the official image registry and Redis prerequisite
  [#38].

## [0.1.2] - 2023-07-18

**Terraform Enterprise appVersion:** `1.16.0`

### Fixed

- Ensured the built-in ConfigMap and Secret remain in `envFrom` when
  `.Values.env.configMapRefs` or `.Values.env.secretRefs` are supplied [#33].

## [0.1.1] - 2023-07-14

**Terraform Enterprise appVersion:** `1.16.0`

This was the first chart version published in the HashiCorp Helm repository.

## [0.1.0] - 2023-07-13

**Terraform Enterprise appVersion:** `1.16.0`

This was the initial tagged development release. No `0.1.0` package is present
in the HashiCorp Helm repository.

### Added

- Added the initial Terraform Enterprise Helm chart.

[Unreleased]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v2.0.7...HEAD
[2.0.7]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v2.0.6...v2.0.7
[2.0.6]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v2.0.5...v2.0.6
[2.0.5]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v2.0.4...v2.0.5
[2.0.4]: https://github.com/hashicorp/terraform-enterprise-helm/compare/ddc6b6a201d1c3e83fd9aa757733ebd62a83f1df...1b1889af92aed650b085c9dffd7f14eba8708fed
[1.6.10]: https://github.com/hashicorp/terraform-enterprise-helm/compare/e1e67d4c76f6c6b1777b746794e806c6209c9b47...40f16a452ea1ce726311c3b040486088bdbeace6
[1.6.9]: https://github.com/hashicorp/terraform-enterprise-helm/compare/f3b6d8b2f0e0b4403874a9995fac8403052cf084...ddc6b6a201d1c3e83fd9aa757733ebd62a83f1df
[1.6.8]: https://github.com/hashicorp/terraform-enterprise-helm/compare/5acd0b839e20a4362ad40b0e55e941bf62985d40...f3b6d8b2f0e0b4403874a9995fac8403052cf084
[1.6.7]: https://github.com/hashicorp/terraform-enterprise-helm/compare/84c3149cab063b1ee37cbc7da208b4350de0ae52...5acd0b839e20a4362ad40b0e55e941bf62985d40
[1.6.6]: https://github.com/hashicorp/terraform-enterprise-helm/compare/aa11b9400e0a7604c1d2dfa54ac309ebf4f59949...84c3149cab063b1ee37cbc7da208b4350de0ae52
[1.6.5]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.6.4...v1.6.5
[1.6.4]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.6.3...v1.6.4
[1.6.3]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.6.2...v1.6.3
[1.6.2]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.6.1...v1.6.2
[1.6.1]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.6.0...v1.6.1
[1.6.0]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.5.0...v1.6.0
[1.5.0]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.4.0...v1.5.0
[1.4.0]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.3.4...v1.4.0
[1.3.4]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.3.3...v1.3.4
[1.3.3]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.3.2...v1.3.3
[1.3.2]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.3.1...v1.3.2
[1.3.1]: https://github.com/hashicorp/terraform-enterprise-helm/compare/b9efdac27442a406a7abdfb305ec2dbb80934331...v1.3.1
[1.3.0]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.2.0...b9efdac27442a406a7abdfb305ec2dbb80934331
[1.2.0]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v0.1.2...v1.0.0
[0.1.2]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/hashicorp/terraform-enterprise-helm/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/hashicorp/terraform-enterprise-helm/releases/tag/v0.1.0

[#33]: https://github.com/hashicorp/terraform-enterprise-helm/pull/33
[#37]: https://github.com/hashicorp/terraform-enterprise-helm/pull/37
[#38]: https://github.com/hashicorp/terraform-enterprise-helm/pull/38
[#39]: https://github.com/hashicorp/terraform-enterprise-helm/pull/39
[#42]: https://github.com/hashicorp/terraform-enterprise-helm/pull/42
[#45]: https://github.com/hashicorp/terraform-enterprise-helm/pull/45
[#46]: https://github.com/hashicorp/terraform-enterprise-helm/pull/46
[#57]: https://github.com/hashicorp/terraform-enterprise-helm/pull/57
[#61]: https://github.com/hashicorp/terraform-enterprise-helm/pull/61
[#62]: https://github.com/hashicorp/terraform-enterprise-helm/pull/62
[#63]: https://github.com/hashicorp/terraform-enterprise-helm/pull/63
[#64]: https://github.com/hashicorp/terraform-enterprise-helm/pull/64
[#65]: https://github.com/hashicorp/terraform-enterprise-helm/pull/65
[#66]: https://github.com/hashicorp/terraform-enterprise-helm/pull/66
[#68]: https://github.com/hashicorp/terraform-enterprise-helm/pull/68
[#71]: https://github.com/hashicorp/terraform-enterprise-helm/pull/71
[#77]: https://github.com/hashicorp/terraform-enterprise-helm/pull/77
[#79]: https://github.com/hashicorp/terraform-enterprise-helm/pull/79
[#87]: https://github.com/hashicorp/terraform-enterprise-helm/pull/87
[#91]: https://github.com/hashicorp/terraform-enterprise-helm/pull/91
[#93]: https://github.com/hashicorp/terraform-enterprise-helm/pull/93
[#95]: https://github.com/hashicorp/terraform-enterprise-helm/pull/95
[#96]: https://github.com/hashicorp/terraform-enterprise-helm/pull/96
[#101]: https://github.com/hashicorp/terraform-enterprise-helm/pull/101
[#103]: https://github.com/hashicorp/terraform-enterprise-helm/pull/103
[#108]: https://github.com/hashicorp/terraform-enterprise-helm/pull/108
[#109]: https://github.com/hashicorp/terraform-enterprise-helm/pull/109
[#111]: https://github.com/hashicorp/terraform-enterprise-helm/pull/111
[#112]: https://github.com/hashicorp/terraform-enterprise-helm/pull/112
[#115]: https://github.com/hashicorp/terraform-enterprise-helm/pull/115
[#118]: https://github.com/hashicorp/terraform-enterprise-helm/pull/118
[#120]: https://github.com/hashicorp/terraform-enterprise-helm/pull/120
[#129]: https://github.com/hashicorp/terraform-enterprise-helm/pull/129
[#133]: https://github.com/hashicorp/terraform-enterprise-helm/pull/133
[#135]: https://github.com/hashicorp/terraform-enterprise-helm/pull/135
[#137]: https://github.com/hashicorp/terraform-enterprise-helm/pull/137
[#139]: https://github.com/hashicorp/terraform-enterprise-helm/pull/139
[#140]: https://github.com/hashicorp/terraform-enterprise-helm/pull/140
[#142]: https://github.com/hashicorp/terraform-enterprise-helm/pull/142
[#157]: https://github.com/hashicorp/terraform-enterprise-helm/pull/157
[#163]: https://github.com/hashicorp/terraform-enterprise-helm/pull/163
[#166]: https://github.com/hashicorp/terraform-enterprise-helm/pull/166
[#208]: https://github.com/hashicorp/terraform-enterprise-helm/pull/208
