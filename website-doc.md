## Pre-upgrade Validation (Flexible Deployment Options / Kubernetes)

Terraform Enterprise on Kubernetes provides a safe, out-of-band pre-upgrade check. This feature validates your infrastructure, database compatibility, and configuration against a target version *before* a production upgrade.

The chart supports two execution paths via `preupgradeCheck.tfeNamespace`:

- `true` (default): run in the existing TFE deployment namespace. This is strict non-mutating behavior for shared Terraform Enterprise resources and renders only the preupgrade Job plus optional preupgrade override Secret.
- `false`: run in a namespace without an existing TFE deployment. Renders only the minimum prerequisites for the preupgrade Job (ConfigMap/Secret, and ServiceAccount when enabled) plus the Job.

### Pre-upgrade Check Workflow

#### 1. Existing Namespace Mode (Strict Non-Mutating)
Target the new release version and run `helm template` piped to `kubectl apply`.

```sh
helm template <release-name> hashicorp/terraform-enterprise \
  --version <target-version> \
  -f your-production-values.yaml \
  --set preupgradeCheck.enabled=true \
  --set preupgradeCheck.tfeNamespace=true \
  --show-only templates/preupgrade-check-job.yaml \
  --show-only templates/preupgrade-check-secret.yaml \
  | kubectl apply -n <namespace> -f -
```

#### 2. Wait and Inspect the Results
Monitor the Job's progress.

```sh
# Wait for completion
kubectl wait --for=condition=complete \
  job/terraform-enterprise-preupgrade-check \
  -n <namespace> --timeout=300s

# Inspect the logs
kubectl logs -l app=terraform-enterprise-preupgrade-check \
  -n <namespace>
```

*If the logs indicate a failure, address the misconfiguration or dependency requirement in your environment before upgrading.*

#### 3. Clean Up Validation Resources
Remove the validation Job and any overrides secret. The Job auto-deletes after `preupgradeCheck.ttlSecondsAfterFinished` seconds, but explicit cleanup is still recommended.

```sh
kubectl delete job/terraform-enterprise-preupgrade-check -n <namespace> --ignore-not-found
kubectl delete secret/terraform-enterprise-preupgrade-check-overrides -n <namespace> --ignore-not-found
```

Optional custom Job naming:

```sh
--set preupgradeCheck.jobName=terraform-enterprise-preupgrade-check-v202601-1
```

When `jobName` is set, use that exact name in `kubectl wait/delete` commands. The
override Secret name becomes `<jobName>-overrides`.

#### 4. Proceed with the Upgrade
Once the pre-upgrade check completes successfully, proceed with the standard upgrade command using the exact same target version and values:

```sh
helm upgrade <release-name> hashicorp/terraform-enterprise \
  --version <target-version> -f your-production-values.yaml
```

### Supplying New Target Configuration
If the target version requires *new* configuration values or secrets that are not yet present in your active environment, you can supply them just for this Job using `preupgradeCheck.extraEnv` and `preupgradeCheck.extraSecrets` in your `values.yaml` file without disrupting production.

### Fresh Namespace Validation
Recommended when possible for maximum isolation and easiest cleanup. If your registry requires credentials, create your `imagePullSecrets` in that namespace first.

```sh
helm install tfe-validation hashicorp/terraform-enterprise \
  -n tfe-validation --create-namespace \
  --version <target-version> \
  -f your-production-values.yaml \
  --set preupgradeCheck.enabled=true \
  --set preupgradeCheck.tfeNamespace=false
```

Cleanup:

```sh
helm uninstall tfe-validation -n tfe-validation
```
