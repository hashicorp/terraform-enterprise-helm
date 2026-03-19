# Terraform Enterprise Upgrades and Version Management

## Pre-upgrade Validation

Before upgrading Terraform Enterprise, run a preupgrade check as a one-shot Kubernetes Job.

What the preupgrade check does:

- Starts the Terraform Enterprise preupgrade-check binary in Kubernetes.
- Validates that required runtime configuration is present and consumable for the target version.
- Verifies core dependency connectivity and readiness.
- Surfaces misconfiguration early so you can fix issues before applying a full Helm upgrade.

This reduces upgrade risk by failing fast in an isolated validation step.

Enable this workflow by setting `preupgradeCheck.enabled=true` for the validation run.

If you are running on Red Hat OpenShift, also set `openshift.enabled=true` in `override.yaml`.

Use `preupgradeCheck.tfeNamespace` to choose execution mode:

1. `true` (default): existing TFE namespace, strict non-mutating behavior for shared Terraform Enterprise resources. Renders only the preupgrade Job and optional override Secret.
2. `false`: namespace without an existing TFE deployment. Renders minimum prerequisites plus the preupgrade Job.

Why the commands differ by mode:

- Existing namespace uses `kubectl apply` from `helm template --show-only` output so you can run validation without creating or mutating Helm release state in the live Terraform Enterprise namespace.
- Fresh namespace uses `helm install` because the validation resources are isolated in a separate release, which gives clean lifecycle management and simple cleanup with `helm uninstall`.

### Existing Namespace

In this mode, the Job reads runtime config from existing in-cluster objects (for example, ConfigMaps and Secrets).

If your required values are stored in existing objects, add refs or keyRefs under `env` in your `override.yaml` file for the preupgrade validation run. Example:

```yaml
env:
  secretRefs:
    - name: env-database-config
    - name: env-redis-secrets
  secretKeyRefs:
    - name: TFE_DATABASE_PASSWORD
      secretName: env-database-config
      key: database_password
```

Run validation:

```sh
helm template <RELEASE> hashicorp/terraform-enterprise \
  --version <NEW_VERSION> \
    -f override.yaml \
    --set preupgradeCheck.enabled=true \
    --set preupgradeCheck.tfeNamespace=true \
    --show-only templates/preupgrade-check-job.yaml \
    --show-only templates/preupgrade-check-secret.yaml \
    | kubectl apply -n <NAMESPACE> -f -
```

Check status and logs:

```sh
kubectl wait --for=condition=complete \
    job/terraform-enterprise-preupgrade-check \
    -n <NAMESPACE> --timeout=300s
  kubectl logs -l app=terraform-enterprise-preupgrade-check -n <NAMESPACE>
```

Optional custom Job name:

```sh
--set preupgradeCheck.jobName=terraform-enterprise-preupgrade-check-2.0.0
```

Use this on the validation command if you need a unique Job name for reruns.

If you need existing release values as a baseline:

```sh
helm get values <RELEASE> -n <NAMESPACE> -a > current-release-values.yaml
```

Clean up:

```sh
kubectl delete job/terraform-enterprise-preupgrade-check -n <NAMESPACE> --ignore-not-found
kubectl delete secret/terraform-enterprise-preupgrade-check-overrides -n <NAMESPACE> --ignore-not-found
```

Proceed with upgrade:

Follow the [Helm Upgrade](#helm-upgrade) instructions below after validation succeeds.

### Fresh Namespace Validation

Recommended for isolated testing and easy cleanup.

```sh
helm install tfe-validation hashicorp/terraform-enterprise \
    -n tfe-validation --create-namespace \
    --version <TARGET_VERSION> \
    -f override.yaml \
    --set preupgradeCheck.enabled=true \
    --set preupgradeCheck.tfeNamespace=false
```

Cleanup:

```sh
helm uninstall tfe-validation -n tfe-validation
```

## Helm Upgrade

The `helm upgrade` command requires a release name and a chart. The chart can be a chart reference (`hashicorp/terraform-enterprise`), a local chart directory, a packaged chart, or a URL.

Generic upgrade syntax:

```sh
helm upgrade [RELEASE] [CHART] [flags]
```

To wait until resources are ready, use `--wait`:

```sh
helm upgrade <RELEASE_NAME> hashicorp/terraform-enterprise \
  --version <TARGET_HELM_CHART_VERSION> \
  --reuse-values \
  --wait \
  --namespace <NAMESPACE>
```

To override chart values, use `-f/--values` for files, `--set` for inline values, `--set-string` for forced strings, and `--set-file` for long or generated values.

```sh
helm upgrade terraform-enterprise hashicorp/terraform-enterprise \
  -n <NAMESPACE> \
  -f values.yaml \
  -f override.yaml
```

For safer upgrades, use `--atomic` to roll back automatically on failure. Helm enables `--wait` automatically when `--atomic` is set.

```sh
helm upgrade terraform-enterprise hashicorp/terraform-enterprise \
  -n <NAMESPACE> \
  -f my-values.yaml \
  --install \
  --atomic
```

## Helm rollback to previous release

The first rollback argument is the release name. The optional second argument is the revision. If you omit the revision, Helm rolls back to the previous release.

To view revisions, run `helm history`:

```sh
helm history <RELEASE_NAME> -n <NAMESPACE>
```

Roll back to the previous release:

```sh
helm rollback <RELEASE_NAME> -n <NAMESPACE>
```

Roll back to a specific revision:

```sh
helm rollback <RELEASE_NAME> <REVISION> -n <NAMESPACE>
```

Use `helm rollback` rather than `kubectl rollout undo` so the full Helm release state is restored, not just Deployment state.

## Upgrade Process Using an Image Tag

Inspect values from the current release:

```sh
helm get values terraform-enterprise -n <NAMESPACE>
```

Export current values to an override file:

```sh
helm get values terraform-enterprise -n <NAMESPACE> -a > override.yaml
```

Update the image tag in `override.yaml`, then run upgrade:

```sh
helm upgrade terraform-enterprise hashicorp/terraform-enterprise \
  -n <NAMESPACE> \
  -f values.yaml \
  -f override.yaml
```

Check revision history and rollout status:

```sh
helm history terraform-enterprise -n <NAMESPACE>
kubectl get pods -n <NAMESPACE>
```

Example history output:

```
REVISION        UPDATED                         STATUS          CHART                           APP VERSION     DESCRIPTION
1               Thu Mar 30 21:07:26 2023        superseded      terraform-enterprise-0.1.0      1.16.0          Install complete
2               Thu Mar 30 14:23:21 2023        deployed        terraform-enterprise-0.1.0      1.16.0          Upgrade complete
```

Note: Shortly after upgrade, pods may still be restarting.

## Rollback Process Using an Image Tag

To roll back using the same values workflow, first ensure you have a current `override.yaml`:

```sh
helm get values terraform-enterprise -n <NAMESPACE> -a > override.yaml
```

Then either:

- run `helm rollback` to a previous revision, or
- update the image tag in `override.yaml` and run `helm upgrade`.

Rollback by revision:

```sh
helm rollback terraform-enterprise -n <NAMESPACE>
```

Check revision history and rollout status:

```sh
helm history terraform-enterprise -n <NAMESPACE>
kubectl get pods -n <NAMESPACE>
```

Note: Shortly after rollback, pods may still be restarting.
