# Charts

This directory contains chart artifacts downloaded using Helm's dependency management function. These artifacts can be restored by executing:

```sh
helm dependency update ./docs/example/terraform-enterprise-prereqs
```

The resulting artifacts should not be committed to git.