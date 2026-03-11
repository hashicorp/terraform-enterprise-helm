# Terraform Enterprise Pre-Upgrade Check Helm Chart

Run TFE pre-upgrade validation checks as a standalone Kubernetes Job — **before** you upgrade.

The pre-upgrade check binary validates your TFE environment (license, database, Redis, object storage, TLS, configuration) without modifying any data. All database connections use `default_transaction_read_only=on`. The only write is a self-cleaning test object in object storage (Archivist check).

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Step-by-Step Guide](#step-by-step-guide)
  - [Step 1: Get the Chart](#step-1-get-the-chart)
  - [Step 2: Prepare Your Configuration](#step-2-prepare-your-configuration)
  - [Step 3: Configure TLS (If Applicable)](#step-3-configure-tls-if-applicable)
  - [Step 4: Configure Image Pull Access](#step-4-configure-image-pull-access)
  - [Step 5: Configure Cloud IAM (If Applicable)](#step-5-configure-cloud-iam-if-applicable)
  - [Step 6: Install the Chart](#step-6-install-the-chart)
  - [Step 7: View Results](#step-7-view-results)
  - [Step 8: Clean Up](#step-8-clean-up)
- [Configuration Modes](#configuration-modes)
  - [Mode A: Env File (--set-file)](#mode-a-env-file---set-file)
  - [Mode B: Structured Values (--set / values.yaml)](#mode-b-structured-values---set--valuesyaml)
- [OpenShift](#openshift)
- [Full Values Reference](#full-values-reference)
- [What Gets Checked](#what-gets-checked)
- [Interpreting Results](#interpreting-results)
- [Troubleshooting](#troubleshooting)
- [Examples](#examples)

## Overview

This chart creates a Kubernetes **Job** that runs `/usr/local/bin/preupgrade-check` inside the TFE container image. The binary performs 14 validation checks against your infrastructure and exits. The Job self-cleans after `ttlSecondsAfterFinished` (default: 1 hour).

**What this chart creates:**
- 1 Secret (your TFE environment variables)
- 1 Job (runs the check binary)
- 1 TLS Secret (optional, only if you provide inline certs)
- 1 ServiceAccount (optional, only if `serviceAccount.create=true`)

**What this chart does NOT create:**
- No Deployment, StatefulSet, or ReplicaSet
- No Service, Ingress, or NetworkPolicy
- No PersistentVolumeClaim
- No RBAC (ClusterRole, RoleBinding, etc.)

## Prerequisites

- **Helm 3.x** installed locally
- **kubectl** configured with access to your target cluster
- **Network access** from the cluster to your TFE infrastructure:
  - PostgreSQL database (port 5432)
  - Redis (port 6379 or 6380 for TLS)
  - Object storage (S3, Azure Blob, or GCS endpoints)
  - HashiCorp licensing endpoint (`licensing.hashicorp.com:443`) — unless using an air-gapped license
- **TFE container image** accessible from the cluster (pull credentials if using a private registry)
- **Your TFE configuration** — the same environment variables you use (or plan to use) for TFE

## Quick Start

If you already have a `tfe.env` file (the same one you use for Docker/Podman TFE deployments):

```bash
# Clone the repo
git clone git@github.com:hashicorp/terraform-enterprise-helm.git
cd terraform-enterprise-helm

# Run the check
helm install preupgrade-check ./charts/terraform-enterprise-preupgrade-check \
  --namespace <your-namespace> \
  --set-file envFile=./path/to/tfe.env

# Wait for completion
kubectl wait --for=condition=complete \
  job/preupgrade-check-terraform-enterprise-preupgrade-check \
  -n <your-namespace> --timeout=300s

# View results
kubectl logs job/preupgrade-check-terraform-enterprise-preupgrade-check \
  -n <your-namespace>

# Clean up
helm uninstall preupgrade-check -n <your-namespace>
```

That's it. Read on for the full walkthrough.

---

## Step-by-Step Guide

### Step 1: Get the Chart

Clone the repository and check out the branch containing the chart:

```bash
git clone git@github.com:hashicorp/terraform-enterprise-helm.git
cd terraform-enterprise-helm
git checkout daniel/preupgrade-check
```

Verify the chart is present:

```bash
ls charts/terraform-enterprise-preupgrade-check/
# Chart.yaml  examples/  templates/  values.yaml
```

### Step 2: Prepare Your Configuration

The chart needs TFE environment variables to know what to check. You have two options:

#### Option A: Use an existing .env file (recommended for Docker/Podman users)

If you already run TFE with a `tfe.env` file (or `docker-compose.env`, etc.), you can use it directly:

```bash
# Example tfe.env file:
TFE_LICENSE=02MV4UU43BK5...
TFE_HOSTNAME=tfe.example.com
TFE_ENCRYPTION_PASSWORD=my-encryption-password
TFE_OPERATIONAL_MODE=active-active
TFE_DATABASE_HOST=db.example.com
TFE_DATABASE_NAME=tfe
TFE_DATABASE_USER=tfe
TFE_DATABASE_PASSWORD=secretpassword
TFE_OBJECT_STORAGE_TYPE=s3
TFE_OBJECT_STORAGE_S3_BUCKET=my-tfe-bucket
TFE_OBJECT_STORAGE_S3_REGION=us-west-2
TFE_REDIS_URL=redis://redis.example.com:6379
```

The parser handles:
- Comments (lines starting with `#`) — skipped
- Blank lines — skipped
- `export ` prefix — stripped automatically
- Quoted values (`"value"` or `'value'`) — quotes stripped
- Values containing `=` (e.g., base64 license keys) — splits on first `=` only

See `examples/tfe.env` for a comprehensive template.

#### Option B: Create a values file (recommended for Kubernetes-native workflows)

Create a `my-values.yaml`:

```yaml
env:
  TFE_LICENSE: "02MV4UU43BK5..."
  TFE_HOSTNAME: "tfe.example.com"
  TFE_ENCRYPTION_PASSWORD: "my-encryption-password"
  TFE_OPERATIONAL_MODE: "active-active"
  TFE_DATABASE_HOST: "db.example.com"
  TFE_DATABASE_NAME: "tfe"
  TFE_DATABASE_USER: "tfe"
  TFE_DATABASE_PASSWORD: "secretpassword"
  TFE_OBJECT_STORAGE_TYPE: "s3"
  TFE_OBJECT_STORAGE_S3_BUCKET: "my-tfe-bucket"
  TFE_OBJECT_STORAGE_S3_REGION: "us-west-2"
  TFE_REDIS_URL: "redis://redis.example.com:6379"
```

> **Note:** If you provide both `envFile` and `env`, the `envFile` takes precedence and `env` is ignored. If you provide neither, the chart fails with a clear error message.

### Step 3: Configure TLS (If Applicable)

If your TFE deployment uses custom TLS certificates, the check binary needs access to them to validate the TLS configuration. There are two ways to provide them:

#### Option A: Reference an existing Kubernetes TLS Secret

If you already have a `kubernetes.io/tls` Secret in the cluster (e.g., from your TFE deployment):

```yaml
# In my-values.yaml
tls:
  certSecret: "my-existing-tls-secret"
```

The chart maps `tls.crt` → `cert.pem` and `tls.key` → `key.pem` automatically.

Make sure your env includes the mount paths:

```yaml
env:
  TFE_TLS_CERT_FILE: "/etc/ssl/private/terraform-enterprise/cert.pem"
  TFE_TLS_KEY_FILE: "/etc/ssl/private/terraform-enterprise/key.pem"
```

#### Option B: Provide inline PEM certificates

```yaml
# In my-values.yaml
tls:
  cert: |
    -----BEGIN CERTIFICATE-----
    MIIFxTCCA62gAwIBAgI...
    -----END CERTIFICATE-----
  key: |
    -----BEGIN RSA PRIVATE KEY-----
    MIIEpAIBAAKCAQEA...
    -----END RSA PRIVATE KEY-----
  caCert: |  # optional
    -----BEGIN CERTIFICATE-----
    MIIFxTCCA62gAwIBAgI...
    -----END CERTIFICATE-----
```

The chart creates a Secret and mounts it at `tls.mountPath` (default: `/etc/ssl/private/terraform-enterprise`).

#### No TLS?

If you're not using custom TLS (e.g., TLS is terminated at a load balancer), skip this step entirely. Don't set `TFE_TLS_CERT_FILE` or `TFE_TLS_KEY_FILE` in your env.

### Step 4: Configure Image Pull Access

The chart uses the official TFE image (`quay.io/hashicorp/terraform-enterprise`). If your cluster requires pull credentials:

```yaml
# In my-values.yaml
image:
  pullSecrets:
    - name: terraform-enterprise
```

Create the pull secret if it doesn't exist:

```bash
kubectl create secret docker-registry terraform-enterprise \
  --docker-server=quay.io \
  --docker-username=<username> \
  --docker-password=<password> \
  -n <your-namespace>
```

To use a specific image version (defaults to the chart's `appVersion`):

```yaml
image:
  tag: "v202503-1"
```

### Step 5: Configure Cloud IAM (If Applicable)

If your TFE uses cloud IAM for object storage access (instead of static credentials), the Job's pod needs a ServiceAccount with the appropriate annotation.

#### AWS (IRSA)

```yaml
serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::123456789012:role/tfe-preupgrade-check"
```

Make sure the IAM role's trust policy allows the ServiceAccount, and omit `TFE_OBJECT_STORAGE_S3_ACCESS_KEY_ID` / `TFE_OBJECT_STORAGE_S3_SECRET_ACCESS_KEY` from your env (or set `TFE_OBJECT_STORAGE_S3_USE_INSTANCE_PROFILE=true`).

#### GCP (Workload Identity)

```yaml
serviceAccount:
  create: true
  annotations:
    iam.gke.io/gcp-service-account: "tfe-preupgrade@my-project.iam.gserviceaccount.com"
```

#### Azure (Workload Identity)

```yaml
serviceAccount:
  create: true
  annotations:
    azure.workload.identity/client-id: "<managed-identity-client-id>"

podLabels:
  azure.workload.identity/use: "true"
```

#### Using an existing ServiceAccount

If you already have a ServiceAccount configured (e.g., from your TFE deployment):

```yaml
serviceAccount:
  create: false
  name: "terraform-enterprise"
```

### Step 6: Install the Chart

**Using an env file:**

```bash
helm install preupgrade-check \
  ./charts/terraform-enterprise-preupgrade-check \
  --namespace tfe \
  --set-file envFile=./tfe.env
```

**Using a values file:**

```bash
helm install preupgrade-check \
  ./charts/terraform-enterprise-preupgrade-check \
  --namespace tfe \
  -f my-values.yaml
```

**Combining options (values file + env file + overrides):**

```bash
helm install preupgrade-check \
  ./charts/terraform-enterprise-preupgrade-check \
  --namespace tfe \
  -f my-values.yaml \
  --set-file envFile=./tfe.env \
  --set image.tag="v202503-1"
```

**Dry run first** (see what would be created without creating anything):

```bash
helm install preupgrade-check \
  ./charts/terraform-enterprise-preupgrade-check \
  --namespace tfe \
  --set-file envFile=./tfe.env \
  --dry-run
```

### Step 7: View Results

Wait for the Job to finish:

```bash
kubectl wait --for=condition=complete \
  job/preupgrade-check-terraform-enterprise-preupgrade-check \
  -n tfe --timeout=300s
```

View the check output:

```bash
kubectl logs job/preupgrade-check-terraform-enterprise-preupgrade-check -n tfe
```

Example output (all checks passing):

```
Pre-upgrade check for Terraform Enterprise

[license]
  [PASS] License is valid
  [PASS] License is not expired

[config]
  [PASS] TFE_HOSTNAME is set
  [PASS] TFE_ENCRYPTION_PASSWORD is set

[tls]
  [PASS] TLS certificate is valid
  [PASS] TLS certificate matches hostname
  [PASS] TLS certificate is not expired

[database]
  [PASS] Database is reachable
  [PASS] Database version is supported
  [PASS] Required extensions are installed

[redis]
  [PASS] Redis is reachable

[object_storage]
  [PASS] Object storage is accessible
  [PASS] Read/write test passed

[upgrade]
  [PASS] No blocking migrations pending
```

**Check the Job status:**

```bash
kubectl get job preupgrade-check-terraform-enterprise-preupgrade-check -n tfe
```

- `COMPLETIONS: 1/1` — all checks ran (check logs for individual pass/fail)
- `COMPLETIONS: 0/1` and pod in `Error` state — the binary crashed or couldn't start (check logs)

**If the Job is still running:**

```bash
# See pod status
kubectl get pods -l app.kubernetes.io/name=terraform-enterprise-preupgrade-check -n tfe

# Stream logs live
kubectl logs -f job/preupgrade-check-terraform-enterprise-preupgrade-check -n tfe
```

### Step 8: Clean Up

The Job self-cleans after `ttlSecondsAfterFinished` (default: 3600 seconds / 1 hour). To clean up immediately:

```bash
helm uninstall preupgrade-check -n tfe
```

This removes the Job, Secret(s), and ServiceAccount (if chart-created).

**To re-run** (e.g., after fixing a failing check):

```bash
# Uninstall the previous run first — Helm won't overwrite an existing Job
helm uninstall preupgrade-check -n tfe

# Then install again
helm install preupgrade-check \
  ./charts/terraform-enterprise-preupgrade-check \
  --namespace tfe \
  --set-file envFile=./tfe.env
```

---

## Configuration Modes

### Mode A: Env File (--set-file)

Best for Docker/Podman users who already have a `tfe.env` file.

```bash
helm install preupgrade-check ./charts/terraform-enterprise-preupgrade-check \
  --set-file envFile=./tfe.env
```

**Parsing rules:**
| Input | Behavior |
|---|---|
| `KEY=value` | Parsed as `KEY: "value"` |
| `KEY="quoted value"` | Quotes stripped: `KEY: "quoted value"` |
| `KEY='single quoted'` | Quotes stripped: `KEY: "single quoted"` |
| `KEY=base64+with==padding` | Safe — splits on first `=` only |
| `export KEY=value` | `export ` stripped: `KEY: "value"` |
| `# comment` | Skipped |
| (blank line) | Skipped |

### Mode B: Structured Values (--set / values.yaml)

Best for Kubernetes-native workflows and GitOps.

```yaml
# my-values.yaml
env:
  TFE_LICENSE: "02MV4UU43BK5..."
  TFE_HOSTNAME: "tfe.example.com"
  TFE_DATABASE_HOST: "db.example.com"
```

```bash
helm install preupgrade-check ./charts/terraform-enterprise-preupgrade-check \
  -f my-values.yaml
```

Or using `--set` for individual values:

```bash
helm install preupgrade-check ./charts/terraform-enterprise-preupgrade-check \
  --set env.TFE_HOSTNAME=tfe.example.com \
  --set env.TFE_LICENSE=02MV4UU43BK5...
```

> **Precedence:** If both `envFile` and `env` are provided, `envFile` wins. If neither is provided, the chart fails with an error.

---

## OpenShift

Enable OpenShift compatibility to apply the restricted security context:

```yaml
openshift:
  enabled: true
```

This sets:
- Pod: `runAsNonRoot: true`
- Container: `allowPrivilegeEscalation: false`, `runAsNonRoot: true`, `capabilities.drop: ["ALL"]`, `seccompProfile.type: RuntimeDefault`

---

## Full Values Reference

| Parameter | Description | Default |
|---|---|---|
| `envFile` | Flat `.env` file content (pass via `--set-file`) | `""` |
| `env` | TFE env vars as key-value map | `{}` |
| `image.repository` | Container image repository | `quay.io/hashicorp/terraform-enterprise` |
| `image.tag` | Image tag (defaults to `appVersion`) | `""` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `image.pullSecrets` | Image pull secret references | `[]` |
| `tls.certSecret` | Name of existing TLS Secret | `""` |
| `tls.cert` | Inline PEM certificate | `""` |
| `tls.key` | Inline PEM private key | `""` |
| `tls.caCert` | Inline PEM CA bundle | `""` |
| `tls.mountPath` | TLS mount path in container | `/etc/ssl/private/terraform-enterprise` |
| `job.backoffLimit` | Job retry attempts | `0` |
| `job.ttlSecondsAfterFinished` | Auto-cleanup delay (seconds) | `3600` |
| `job.activeDeadlineSeconds` | Max Job runtime (seconds) | `300` |
| `resources.requests.cpu` | CPU request | `100m` |
| `resources.requests.memory` | Memory request | `128Mi` |
| `resources.limits.memory` | Memory limit | `256Mi` |
| `serviceAccount.create` | Create a ServiceAccount | `false` |
| `serviceAccount.name` | Existing ServiceAccount name | `""` |
| `serviceAccount.annotations` | ServiceAccount annotations | `{}` |
| `openshift.enabled` | Apply OpenShift security context | `false` |
| `podAnnotations` | Additional pod annotations | `{}` |
| `podLabels` | Additional pod labels | `{}` |
| `nodeSelector` | Node selector constraints | `{}` |
| `tolerations` | Pod tolerations | `[]` |
| `affinity` | Pod affinity rules | `{}` |

---

## What Gets Checked

The binary runs up to 14 checks across 7 categories:

| Category | Checks | What It Validates |
|---|---|---|
| **License** | 2 | License format is valid; license is not expired |
| **Config** | 2 | `TFE_HOSTNAME` is set; `TFE_ENCRYPTION_PASSWORD` is set |
| **TLS** | 3 | Certificate is valid PEM; matches hostname; not expired |
| **Database** | 3 | PostgreSQL is reachable; version is supported (>=12); required extensions installed (`citext`, `hstore`, `uuid-ossp`) |
| **Redis** | 1 | Redis is reachable and responds to PING |
| **Object Storage** | 2 | Storage endpoint is accessible; read/write test passes (self-cleaning) |
| **Upgrade** | 1 | No blocking schema migrations pending |

The exact number of checks varies by configuration. For example, TLS checks are skipped if `TFE_TLS_CERT_FILE` is not set, and object storage checks vary by provider.

---

## Interpreting Results

### Exit Codes

| Exit Code | Meaning |
|---|---|
| `0` | All checks passed |
| `1` | One or more checks failed |

The Job's `condition=complete` means the binary ran and exited `0`. If any check fails, the pod exits `1` and the Job shows as `Failed`.

### Output Format

Each check prints `[PASS]` or `[FAIL]` with a description. Failed checks include the error detail:

```
[database]
  [PASS] Database is reachable
  [FAIL] Database version is supported
         PostgreSQL version 11.4 is below minimum required version 12
```

### JSON Output

Set `TFE_PREUPGRADE_CHECK_OUTPUT_FORMAT=json` in your env for machine-readable output:

```bash
# In tfe.env:
TFE_PREUPGRADE_CHECK_OUTPUT_FORMAT=json

# Or via --set:
helm install preupgrade-check ./charts/terraform-enterprise-preupgrade-check \
  --set-file envFile=./tfe.env \
  --set env.TFE_PREUPGRADE_CHECK_OUTPUT_FORMAT=json
```

---

## Troubleshooting

### Chart fails with "You must provide TFE configuration"

You didn't pass any configuration. Use `--set-file envFile=./tfe.env` or `-f my-values.yaml` with an `env:` block.

### Pod stuck in ImagePullBackOff

The cluster can't pull the TFE image. Check:
1. `image.pullSecrets` is set correctly
2. The pull secret exists in the target namespace
3. The image tag exists: `docker pull quay.io/hashicorp/terraform-enterprise:v202503-1`

### Pod stuck in Pending

The cluster can't schedule the pod. Check:
1. Resource requests vs. available capacity: `kubectl describe pod <pod-name> -n tfe`
2. `nodeSelector`, `tolerations`, and `affinity` match available nodes

### "context canceled" or "closed pool" errors

This happens when running inside a live TFE pod (not applicable when using this chart). The standalone chart runs in its own pod with its own connection pool, so this should not occur. If it does, your database may be at max connections — check `max_connections` in PostgreSQL.

### Database connection refused

1. Verify network path: `kubectl run debug --rm -it --image=busybox -n tfe -- nc -zv <db-host> 5432`
2. Check security groups / firewall rules allow traffic from the cluster's pod CIDR
3. If using RDS, check the VPC security group allows the EKS node security group

### Redis connection refused

1. Verify network path: `kubectl run debug --rm -it --image=busybox -n tfe -- nc -zv <redis-host> 6379`
2. If using ElastiCache, check the security group allows the EKS node security group
3. If Redis uses TLS, ensure `TFE_REDIS_USE_TLS=true` is set

### Object storage access denied

1. If using IRSA/Workload Identity, verify `serviceAccount.create=true` and the annotation is correct
2. Check the IAM role/policy allows `s3:GetObject`, `s3:PutObject`, `s3:DeleteObject` on the bucket
3. If using static credentials, verify `TFE_OBJECT_STORAGE_S3_ACCESS_KEY_ID` and `TFE_OBJECT_STORAGE_S3_SECRET_ACCESS_KEY` are set

### TLS check fails

1. Verify the certificate matches `TFE_HOSTNAME`
2. Check the certificate chain is complete (intermediate certs included)
3. Ensure the certificate is not expired: `openssl x509 -in cert.pem -noout -dates`
4. Verify `TFE_TLS_CERT_FILE` and `TFE_TLS_KEY_FILE` point to the correct mount paths (default: `/etc/ssl/private/terraform-enterprise/cert.pem` and `key.pem`)

### Re-running after a failure

Helm won't let you install over an existing release. Uninstall first:

```bash
helm uninstall preupgrade-check -n tfe
helm install preupgrade-check ./charts/terraform-enterprise-preupgrade-check \
  --set-file envFile=./tfe.env -n tfe
```

Or use `helm upgrade --install` to make re-runs idempotent:

```bash
helm upgrade --install preupgrade-check \
  ./charts/terraform-enterprise-preupgrade-check \
  --namespace tfe \
  --set-file envFile=./tfe.env
```

> **Note:** `helm upgrade --install` may leave a completed Job pod behind if the previous run's TTL hasn't expired. If you see `Invalid value: "preupgrade-check": is invalid`, delete the old Job first: `kubectl delete job preupgrade-check-terraform-enterprise-preupgrade-check -n tfe`.

---

## Examples

### Minimal: env file only

```bash
helm install preupgrade-check ./charts/terraform-enterprise-preupgrade-check \
  -n tfe --set-file envFile=./tfe.env
```

### With TLS from existing Secret

```bash
helm install preupgrade-check ./charts/terraform-enterprise-preupgrade-check \
  -n tfe \
  --set-file envFile=./tfe.env \
  --set tls.certSecret=tfe-tls-cert
```

### With AWS IRSA

```bash
helm install preupgrade-check ./charts/terraform-enterprise-preupgrade-check \
  -n tfe \
  --set-file envFile=./tfe.env \
  --set serviceAccount.create=true \
  --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="arn:aws:iam::123456789012:role/tfe-role"
```

### With custom image and namespace creation

```bash
helm install preupgrade-check ./charts/terraform-enterprise-preupgrade-check \
  --create-namespace -n tfe-precheck \
  --set-file envFile=./tfe.env \
  --set image.tag=v202503-1 \
  --set image.pullSecrets[0].name=quay-creds
```

### OpenShift

```bash
helm install preupgrade-check ./charts/terraform-enterprise-preupgrade-check \
  -n tfe \
  --set-file envFile=./tfe.env \
  --set openshift.enabled=true
```

### Full values file

```yaml
# preupgrade-values.yaml
envFile: ""  # Using env map instead

env:
  TFE_LICENSE: "02MV4UU43BK5..."
  TFE_HOSTNAME: "tfe.example.com"
  TFE_ENCRYPTION_PASSWORD: "my-secret"
  TFE_OPERATIONAL_MODE: "active-active"
  TFE_DATABASE_HOST: "tfe-db.cluster-abc.us-west-2.rds.amazonaws.com"
  TFE_DATABASE_NAME: "tfe"
  TFE_DATABASE_USER: "tfe"
  TFE_DATABASE_PASSWORD: "db-secret"
  TFE_DATABASE_PARAMETERS: "sslmode=require"
  TFE_OBJECT_STORAGE_TYPE: "s3"
  TFE_OBJECT_STORAGE_S3_BUCKET: "my-tfe-bucket"
  TFE_OBJECT_STORAGE_S3_REGION: "us-west-2"
  TFE_OBJECT_STORAGE_S3_USE_INSTANCE_PROFILE: "true"
  TFE_REDIS_URL: "rediss://master.tfe-redis.abc.usw2.cache.amazonaws.com:6380"
  TFE_REDIS_USE_TLS: "true"
  TFE_TLS_CERT_FILE: "/etc/ssl/private/terraform-enterprise/cert.pem"
  TFE_TLS_KEY_FILE: "/etc/ssl/private/terraform-enterprise/key.pem"

image:
  tag: "v202503-1"
  pullSecrets:
    - name: terraform-enterprise

tls:
  certSecret: "tfe-tls"

serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::123456789012:role/tfe-preupgrade-check"

job:
  activeDeadlineSeconds: 600
  ttlSecondsAfterFinished: 7200

resources:
  requests:
    cpu: 200m
    memory: 256Mi
  limits:
    memory: 512Mi

nodeSelector:
  kubernetes.io/os: linux

tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "tfe"
    effect: "NoSchedule"
```

```bash
helm install preupgrade-check ./charts/terraform-enterprise-preupgrade-check \
  -n tfe -f preupgrade-values.yaml
```
