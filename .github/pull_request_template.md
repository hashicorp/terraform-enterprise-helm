## Summary

<!-- What changed in 1-3 sentences? -->

## Background

<!-- Why is this change needed? Link issues, incidents, or prior PRs if helpful. -->

## Helm Chart Impact

- Does this PR make a substantial change to the Helm chart architecture? If yes, describe.

- Does this PR change rendered Kubernetes resources, chart defaults, upgrade/rollback behavior, or security-sensitive areas such as RBAC, secrets, ingress/networking, storage, or availability? If yes, describe.

## Testing

<!-- How has this been tested? Include commands, values files, environment/cluster details, manual verification, and any gaps. -->
<!-- Suggested validation:
- helm lint .
- helm template . | ./kubeconform --strict
-->

## Reviewer Notes

<!-- Point reviewers to tricky areas, non-goals, or follow-up work. -->

## PCI review checklist

<!-- heimdall_github_prtemplate:grc-pci_dss-2024-01-05 -->

- [ ] I have documented a clear reason for, and description of, the change I am making.

- [ ] If applicable, I've documented a plan to revert these changes if they require more than reverting the pull request.

- [ ] If applicable, I've documented the impact of any changes to security controls.

  Examples of changes to security controls include using new access control methods, adding or removing logging pipelines, etc.
