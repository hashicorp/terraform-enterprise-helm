## Pre-upgrade Validation (Flexible Deployment Options / Kubernetes)

Starting in upcoming releases, Terraform Enterprise on Kubernetes provides a safe, out-of-band pre-upgrade check. This feature allows you to validate your infrastructure, database compatibility, and configuration against a new version of Terraform Enterprise *before* modifying your running production deployment.

The pre-upgrade check runs as an ephemeral Kubernetes Job in the same namespace as your active deployment. By setting the `preupgradeCheck.enabled` flag to `true`, the Helm chart safely suppresses the rendering of core Terraform Enterprise resources (such as the Deployment and Service). It outputs only the validation Job, which natively inherits your existing namespace credentials like `imagePullSecrets` and `serviceAccount`.

### Pre-upgrade Check Workflow

#### 1. Render and Apply the Validation Job
Target the new release version and run the `helm template` command piped to `kubectl apply`. This creates the `terraform-enterprise-preupgrade-check` Job in your existing namespace without changing the active Helm release state.

```sh
helm template <release-name> hashicorp/terraform-enterprise \
  --version <target-version> \
  -f your-production-values.yaml \
  --set preupgradeCheck.enabled=true \
  | kubectl apply -n <namespace> -f -
```

#### 2. Wait and Inspect the Results
Monitor the Job's progress. It will connect to your external dependencies and run a suite of infrastructure validations.

```sh
# Wait for completion
kubectl wait --for=condition=complete \
  job/terraform-enterprise-preupgrade-check \
  -n <namespace> --timeout=300s

# Inspect the logs
kubectl logs -l job-name=terraform-enterprise-preupgrade-check \
  -n <namespace>
```

*If the logs indicate a failure, address the misconfiguration or dependency requirement in your environment before upgrading.*

#### 3. Clean Up Validation Resources
Remove the validation Job and any overrides secret to keep your cluster state clean. Note: The Job includes a `ttlSecondsAfterFinished` lifecycle to auto-delete after an hour, but manual deletion is recommended immediately and required for the configured secret.

```sh
kubectl delete job/terraform-enterprise-preupgrade-check -n <namespace> --ignore-not-found
kubectl delete secret/terraform-enterprise-preupgrade-check-overrides -n <namespace> --ignore-not-found
```

#### 4. Proceed with the Upgrade
Once the pre-upgrade check completes successfully, proceed with the standard upgrade command using the exact same target version and values:

```sh
helm upgrade <release-name> hashicorp/terraform-enterprise \
  --version <target-version> -f your-production-values.yaml
```

### Supplying New Target Configuration
If the target version requires *new* configuration values or secrets that are not yet present in your active environment, you can supply them just for this Job using `preupgradeCheck.extraEnv` and `preupgradeCheck.extraSecrets` in your `values.yaml` file without disrupting production.
