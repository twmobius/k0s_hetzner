# Changelog

## v2.2.1

  * Fix mount failing if the cluster uses a different kubelet lib path than standard (`/var/lib/k0s/kubelet/pv/pvc-<...>/globalmount: file not found` ) (!3 by @jabbrwcky)

## v2.2.0

  * Add variable `storageClass.reclaimPolicy` to enable configuration of the StorageClass reclaimPoliy (!2 by @morremeyer)
  * Updated `bitnami/common` dependency to v1.11.1

## v2.1.0

  * Add variable `node.kubeletPath` in `values.yaml` to enable configuring kubelet lib
    path (e.g. for [k0sproject](https://k0sproject.io/), which uses `/var/lib/k0s/kubelet` instead of `/var/lib/kubelet`) #8, !1
  * Updated `bitnami/common` dependency to v1.10.4

## v2.0.1

  * Added JSON Schema Support (see `values.schema.json`)

## v2.0.0

**Important notice:**
This release is a major release and comes with an extensive restructuring and therefore a lot of breaking changes!
Please adjust the values carefully before upgrading.

  * General restructuring of `values.yaml`
  * Use `bitnami/common` chart for common naming
  * Upgraded hcloud-csi-driver to v1.6.0 (#7)


## v1.1.3

  * Fixed ArtifactHub image annotations

## v1.1.2

  * Added workaround for ArtifactHub Image Scanning Errors (see https://github.com/artifacthub/hub/issues/1387)

## v1.1.1

  * Fixed Chart icon URL (broken due to branch renaming)

## v1.1.0

  * Changed default ImagePullPolicy to `IfNotPresent`
  * Added support for custom labels and annotations for DaemonSet and StatefulSet Pod templates (#6)

## v1.0.7

  * Upgraded to hcloud-csi-driver v1.5.3

## v1.0.6

  * Fixed image tag for version 1.5.2 -> v1.5.2

## v1.0.5

  * Upgraded to hcloud-csi-driver v1.5.2

## v1.0.4

  * Upgraded to hcloud-csi-driver v1.5.1 (#3)
  * Introduced configuration variables `csiDriver.image` and `csiDriver.imagePullPolicy`

## v1.0.3

  * Upgraded to hcloud-csi-driver v1.5.0 (#2)

## v1.0.2

  * Fixed naming interference with hcloud-cloud-controller-manager helm chart (#1)

## v1.0.1

  * Added logo/icon

## v1.0.0

  * First release
