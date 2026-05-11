# Terraform Enterprise Upgrades and Version Management

## Pre-upgrade Validation

Before upgrading Terraform Enterprise, run a preupgrade check as a standalone Kubernetes Job.

What the preupgrade check does:

- Starts the Terraform Enterprise preupgrade-check binary in Kubernetes / OpenShift.
- Validates that required runtime configuration is present and consumable for the target version.
- Verifies core dependency connectivity and readiness.
- Surfaces misconfiguration early so you can fix issues before applying a full Helm upgrade.

This reduces upgrade risk by failing fast in an isolated validation step.

Note: the preupgrade check runs as a standalone validation Job and is non-destructive — it reads ConfigMaps, Secrets, and external endpoints to validate configuration and connectivity but does not modify the database, change live resources, or interrupt running workspaces, nodes, or active runs.

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
- `override.yaml` is only an example filename. Use the same values override file that you already use for your Terraform Enterprise installation.
- `<TARGET_TFE_VERSION>` is the Terraform Enterprise image tag you want to validate. Pass it with `--set image.tag=<TARGET_TFE_VERSION>` in the commands below.

If you still have the values override file from your original installation, reuse that file for preupgrade validation or export the currently deployed values into a file and use that as your starting point with the command below:

```sh
helm get values <RELEASE_NAME> -n <NAMESPACE> -a -o yaml > override.yaml
```

### Existing Namespace

Set `preupgradeCheck.tfeNamespace=true` for this mode. This is usually the quickest path because the Job reads runtime config from existing in-cluster objects such as ConfigMaps and Secrets.

Run validation:

Step 1: render the Job manifest.

```sh
helm template <RELEASE_NAME> hashicorp/terraform-enterprise \
  -n <NAMESPACE> \
  --version <TARGET_CHART_VERSION> \
  -f override.yaml \
  --set preupgradeCheck.enabled=true \
  --set preupgradeCheck.tfeNamespace=true \
  --set image.tag=<TARGET_TFE_VERSION> \
  --show-only templates/preupgrade-check-job.yaml \
  > preupgrade.yaml
```

If you are running on Red Hat OpenShift and your live values file does not already set it, append `--set openshift.enabled=true` to the command above.

If the target version requires sensitive values that are new, renamed, or different from your in-cluster Secrets, put `preupgradeCheck.extraSecrets` in a separate values file, add that file with an additional `-f` flag, and include `--show-only templates/preupgrade-check-secret.yaml` when rendering `preupgrade.yaml`.

Step 2: apply the rendered manifest.

```sh
kubectl apply -n <NAMESPACE> -f preupgrade.yaml
```

Check status and logs:

By default the Job is named `terraform-enterprise-preupgrade-check`. Use this value to wait for completion and retrieve logs.

```sh
kubectl wait --for=condition=complete \
  job/terraform-enterprise-preupgrade-check \
  -n <NAMESPACE> --timeout=300s

kubectl logs -l preupgrade-check.hashicorp.com/name=terraform-enterprise-preupgrade-check -n <NAMESPACE>
```

Clean up:

```sh
kubectl delete job/terraform-enterprise-preupgrade-check -n <NAMESPACE> --ignore-not-found

kubectl delete secret/terraform-enterprise-preupgrade-check-overrides -n <NAMESPACE> --ignore-not-found
```

Proceed with upgrade:

Follow the [Helm Upgrade](#helm-upgrade) instructions below after validation succeeds.

### Fresh Namespace Validation

Set `preupgradeCheck.tfeNamespace=false` for this mode. Use it when you want isolation from the live namespace, or when you want to validate that your Helm values alone can supply all minimum prerequisites in a new deployment. This flag changes the chart to render the fresh-namespace validation resources. It does not create the namespace by itself.

**Note on configuration:** Because this mode runs in a separate namespace, the validation Job cannot read your existing in-cluster ConfigMaps and Secrets. Reuse the same values override file you normally use for Terraform Enterprise as your starting point or export the values from the running release (`helm get values <RELEASE_NAME> -n <NAMESPACE> -a -o yaml > override.yaml`) and use that as your starting point instead of building a new file from scratch. However, if your live namespace relies on manually created Kubernetes Secrets, such as database passwords or certificates, you must explicitly supply those values for this validation run through your values file or additional values inputs.

Run validation:

The command below installs the chart into a new namespace named `tfe-validation`. The namespace is created by Helm because the command includes `-n tfe-validation --create-namespace`.

```sh
helm install tfe-validation hashicorp/terraform-enterprise \
  -n tfe-validation --create-namespace \
  --version <TARGET_CHART_VERSION> \
  -f override.yaml \
  --set preupgradeCheck.enabled=true \
  --set preupgradeCheck.tfeNamespace=false \
  --set image.tag=<TARGET_TFE_VERSION>
```

If you are running on Red Hat OpenShift and your live values file does not already set it, append `--set openshift.enabled=true` to the command above.

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

### Advanced: Optional Custom Job Name

Use a custom Job name when you want to rerun validation without waiting for the previous Job object to be deleted in an Existing Namespace run.

```sh
--set preupgradeCheck.jobName=terraform-enterprise-preupgrade-check-2-0-0
```

The name must be a valid Kubernetes DNS label. If you use this option, substitute the same Job name in your `kubectl wait`, `kubectl logs`, and cleanup commands. If you are also setting `preupgradeCheck.extraSecrets`, the chart generates a Secret named `<JOB_NAME>-overrides`.

For cleanup, replace `terraform-enterprise-preupgrade-check` with that name and replace the Secret name with `<JOB_NAME>-overrides`.

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
helm get values terraform-enterprise -n <NAMESPACE> -a -o yaml > override.yaml
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
helm get values terraform-enterprise -n <NAMESPACE> -a -o yaml > override.yaml
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
