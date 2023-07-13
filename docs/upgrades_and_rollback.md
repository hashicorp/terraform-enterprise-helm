# Terraform Enterprise Upgrades and Version Management

## helm upgrade

The upgrade arguments must be a release and chart or update SHAs in the helm values. The chart argument can be either: a chart reference(`charts/terraform-enterprise`), a path to a chart directory, a packaged chart, or a fully qualified URL. For chart references, the latest version will be specified unless the `--version` flag is set.

This is a generic command to upgrade a release:

    helm upgrade [RELEASE] [CHART] [flags]

If you want to wait until the pods become ready, you can use a `--wait` flag

    helm upgrade <release-name> hashicrop/terraform-enterprise \
     --version <target-helm-chart-version> \
     --reuse-values \
     --wait \
     --namespace <namespace>

To override values in a chart, use either the `--values` flag and pass in a file or use the `--set` flag and pass configuration from the command line, to force string values, use `--set-string`. You can use `--set-file` to set individual values from a file when the value itself is too long for the command line or is dynamically generated. If a namespace is set, make sure to use the `-n` flag along with the name of the namespace.

    helm upgrade -f values.yaml -f override.yaml terraform-enterprise -n <NAMESPACE>

If you want Helm to rollback installation if it fails, you can use the `--atomic flag`. Note that the `--wait` flag will be set automatically if `--atomic` is used.

    helm upgrade -f my-values.yaml ./path/to/my/chart --install --atomic -n <NAMESPACE> 

## Helm rollback to previous release

The first argument of the rollback command is the name of a release, and the second is a revision (version) number. If this argument is omitted, it will roll back to the previous release.

To see revision numbers, run `helm history RELEASE`  or `helm ls`.

    helm rollback <RELEASE_NAME> -n <NAMESPACE>

Note: The helm rollback command is recommended because using the kubectl command will only rollback the deployment, but not other resources associated with helm release.

But if you need to rollback to specific previous version, You can:

List revision numbers by running:

    helm history <RELEASE_NAME>

Then, rollback to the version you want using:

    helm rollback <RELEASE_NAME> [REVISION]

## Process for Upgrading Terraform Enterprise with Helm using the image tag

In the resulting folder, go to the directory named after your chart.

Inspect the values from the Terraform Enterprise K8s cluster, by running:

    helm get values terraform-enterprise -n <NAMESPACE>

After inspecting the helm values, print the output to an `override.yaml` file, by running:

    helm get values terraform-enterprise -n <NAMESPACE>  > override.yaml

Inside the `override.yaml` file, update the image tag to the version you want for the Terraform Enterprise upgrade and save the file.

To upgrade Terraform Enterprise, run the following commands:

    helm upgrade -f values.yaml -f override.yaml terraform-enterprise -n <NAMESPACE> .

Check the status and version history by running:

    helm history terraform-enterprise -n <NAMESPACE>

Check the deployment status of the pods using the following command:

    kubectl get nodes -n <NAMESPACE>

You should see multiple revisions and an upgrade complete description, for example:

```
REVISION        UPDATED                         STATUS          CHART                           APP VERSION     DESCRIPTION
1               Thu Mar 30 21:07:26 2023        superseded      terraform-enterprise-0.1.0      1.16.0          Install complete
2               Thu Mar 30 14:23:21 2023        deployed        terraform-enterprise-0.1.0      1.16.0          Upgrade complete
```

Note: Depending on how quickly you check the status after running the upgrade, the pods may still be getting recreated.

## Helm Rollback process for Terraform Enterprise using the image tag

To rollback a Terraform Enterprise release we'll use the same approach as upgrading, by using the image tag. Make sure you have a current `override.yaml` file, if not print out the following command:

    helm get values terraform-enterprise -n <NAMESPACE>  > override.yaml

Once you've updated the image tag to the version you want to rollback to, execute the rollback process by running the following command:

    helm rollback terraform-enterprise -n <NAMESPACE>

Check the status and version history by running:

    helm history terraform-enterprise -n <NAMESPACE>

Check the deployment status of the pods using the following command:

    kubectl get nodes -n <NAMESPACE>

Note: Depending on how quickly you check the status after running the upgrade, the pods may still be getting recreated.