# Terraform Enterprise Upgrades and Version Management

## Pre-upgrade Validation

Before upgrading Terraform Enterprise, run a preupgrade check as a one-shot Kubernetes Job.

What the preupgrade check does:

- Starts the Terraform Enterprise preupgrade-check binary in Kubernetes / OpenShift.
- Validates that required runtime configuration is present and consumable for the target version.
- Verifies core dependency connectivity and readiness.
- Surfaces misconfiguration early so you can fix issues before applying a full Helm upgrade.

This reduces upgrade risk by failing fast in an isolated validation step.

Enable this workflow by setting `preupgradeCheck.enabled=true` for the validation run.

If you are running on Red Hat OpenShift, also set `openshift.enabled=true` in your values file e.g `override.yaml`.

### Before You Start

Choose the validation mode that matches how much isolation you want:

- Existing namespace: usually the simplest option. It reuses the current Terraform Enterprise ConfigMaps and Secrets and does not create Helm release state in the live namespace.
- Fresh namespace: use this when you want an isolated validation release in a separate namespace.

Use the Helm chart version whose `appVersion` matches the Terraform Enterprise version you want to validate. For example, if your current deployment is running Terraform Enterprise 1.2.0 and you want to upgrade to Terraform Enterprise 2.0.0, first get the chart release whose `appVersion` is 2.0.0, then run the preupgrade check with that chart version.

If you are using the HashiCorp Helm repository, refresh it and inspect the available chart versions first:

```sh
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update
helm search repo hashicorp/terraform-enterprise --versions
```

Use the `APP VERSION` column in the output to identify the chart release for your target Terraform Enterprise version.

In the preupgrade validation commands below:

- `<RELEASE_NAME>` is your existing Helm release name, for example `terraform-enterprise`.
- `<NAMESPACE>` is the namespace for that release.
- `<TARGET_CHART_VERSION>` is the Helm chart version passed to `--version`. Choose the chart release whose `appVersion` matches the Terraform Enterprise version you want to validate.
- `image.tag` in `override.yaml` is the target Terraform Enterprise application version you plan to validate and then upgrade to.

If you want to start from the currently deployed values, export them first. This is especially useful for fresh namespace validation, because that mode relies on your values file instead of existing in-cluster Terraform Enterprise objects.

```sh
helm get values <RELEASE_NAME> -n <NAMESPACE> -a > override.yaml
```

Update `override.yaml` with the target `image.tag` and any validation-only overrides before running the commands below.

### Existing Namespace

Set `preupgradeCheck.tfeNamespace=true` for this mode. This is usually the quickest path because the Job reads runtime config from existing in-cluster objects such as ConfigMaps and Secrets.

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

Use this command when you are not setting `preupgradeCheck.extraSecrets`:

```sh
helm template <RELEASE_NAME> hashicorp/terraform-enterprise \
  -n <NAMESPACE> \
  --version <TARGET_CHART_VERSION> \
  -f override.yaml \
  --set preupgradeCheck.enabled=true \
  --set preupgradeCheck.tfeNamespace=true \
  --show-only templates/preupgrade-check-job.yaml \
  | kubectl apply -n <NAMESPACE> -f -
```

If you are setting `preupgradeCheck.extraSecrets`, include the secret template as well:

Use `preupgradeCheck.extraSecrets` when the target version needs sensitive values that are new, renamed, or different from what currently exists in your in-cluster Secrets.

```sh
helm template <RELEASE_NAME> hashicorp/terraform-enterprise \
  -n <NAMESPACE> \
  --version <TARGET_CHART_VERSION> \
  -f override.yaml \
  --set preupgradeCheck.enabled=true \
  --set preupgradeCheck.tfeNamespace=true \
  --show-only templates/preupgrade-check-job.yaml \
  --show-only templates/preupgrade-check-secret.yaml \
  | kubectl apply -n <NAMESPACE> -f -
```

Check status and logs:

By default the Job is named `terraform-enterprise-preupgrade-check`. If you set `preupgradeCheck.jobName`, use that same value in the commands below.

```sh
kubectl wait --for=condition=complete \
  job/terraform-enterprise-preupgrade-check \
  -n <NAMESPACE> --timeout=300s
kubectl logs -l preupgrade-check.hashicorp.com/name=terraform-enterprise-preupgrade-check -n <NAMESPACE>
```

Optional custom Job name:

Use a custom Job name when you want to rerun validation without waiting for the previous Job object to be deleted.

```sh
--set preupgradeCheck.jobName=terraform-enterprise-preupgrade-check-2-0-0
```

The name must be a valid Kubernetes DNS label. If you use this option, substitute the same Job name in your `kubectl wait`, `kubectl logs`, and cleanup commands. If you are also setting `preupgradeCheck.extraSecrets`, the chart generates a Secret named `<JOB_NAME>-overrides`.

Clean up:

If you used a custom Job name, replace `terraform-enterprise-preupgrade-check` below with that name and replace the Secret name with `<JOB_NAME>-overrides`.

```sh
kubectl delete job/terraform-enterprise-preupgrade-check -n <NAMESPACE> --ignore-not-found
kubectl delete secret/terraform-enterprise-preupgrade-check-overrides -n <NAMESPACE> --ignore-not-found
```

Proceed with upgrade:

Follow the [Helm Upgrade](#helm-upgrade) instructions below after validation succeeds.

### Fresh Namespace Validation

Set `preupgradeCheck.tfeNamespace=false` for this mode. Use it when you want isolation from the live namespace, or when you want to validate that your values file can supply the minimum prerequisites in a separate release.

The command below creates a new namespace named `tfe-validation`.

```sh
helm install tfe-validation hashicorp/terraform-enterprise \
  -n tfe-validation --create-namespace \
  --version <TARGET_CHART_VERSION> \
  -f override.yaml \
  --set preupgradeCheck.enabled=true \
  --set preupgradeCheck.tfeNamespace=false
```

Check status and logs before cleanup:

```sh
kubectl wait --for=condition=complete \
  job/terraform-enterprise-preupgrade-check \
  -n tfe-validation --timeout=300s
kubectl logs -l preupgrade-check.hashicorp.com/name=terraform-enterprise-preupgrade-check -n tfe-validation
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
  --version <TARGET_CHART_VERSION> \
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
