# Tenable Enclave Security (TES) Helm Chart

![Version: 1.7.0](https://img.shields.io/badge/Version-1.7.0-informational?style=flat-square)
![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)
![AppVersion: 1.7.0](https://img.shields.io/badge/AppVersion-1.7.0-informational?style=flat-square)

This chart bootstraps a Tenable Enclave Security deployment on a Kubernetes cluster using the Helm package manager. It installs the tes-operator, which configures and installs Tenable Enclave Security components.

> **Note:** This README is for the current chart version only. To view documentation for a previous version:
> ```bash
> # Extract the README and view in your preferred markdown viewer
> 
> helm show readme <repo-name>/tes-operator --version <version> > README.md
> ```
> For TES versions prior to 1.7, Helm options were documented here: https://docs.tenable.com/enclave-security/Content/helm-charts.htm

## Table of Contents

- [Prerequisites](#prerequisites)
- [Configuration Options](#configuration-options)
  - [Disable Cluster Scope](#disable-cluster-scope)
  - [Specify CPU and Memory Requests and Limits](#specify-cpu-and-memory-requests-and-limits)
  - [Specify Service Annotations](#specify-service-annotations)
  - [Restrict Access to LoadBalancer](#restrict-access-to-loadbalancer)
  - [Specify Node Affinity](#specify-node-affinity)
  - [Disable cert-manager CSI Driver](#disable-cert-manager-csi-driver)
  - [Specify PVC Size](#specify-pvc-size)
  - [Specify PVC Storage Class](#specify-pvc-storage-class)
  - [Specify Registry for TES Images](#specify-registry-for-tes-images)
  - [Specify Registry for PostgreSQL DB Image](#specify-registry-for-postgresql-db-image)
  - [Change Service Type](#change-service-type)
  - [Configure Routable URL](#configure-routable-url)
  - [External DNS Annotation](#external-dns-annotation)
- [Global TES Settings](#global-tes-settings)
- [Important Notes](#important-notes)
- [Additional Resources](#additional-resources)
## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- An amd64 node type (required)
- A valid Tenable license
- Postgres database (Supported Versions: 14, 15, 16, 17)

## Configuration Options

### Deploy from a private registry

The below helm values can be used to override the default registry and optionally specify an imagePullSecret.

```yaml
operator:
  image:
    registry: myregistry.example.com # private image registry hostname
    imagePullSecret: registrypullsecret # private image registry access secret, if needed
```

### Specify Registry for PostgreSQL DB Image

You can use the following option to specify the PostgreSQL DB image registry.

```yaml
tes:
  blades:
    global:
      db:
        initJob:
          image:
            registry: myregistry.example.com
```

### Disable Cluster Scope

When licensing by namespaceID, disable cluster level roles:

```yaml
tes:
  blades:
    global:
      scopeCluster: false
```

### Specify CPU and Memory Requests and Limits

Example for an environment with 10,000 active IPs:

```yaml
tes:
  blades:
    securitycenter:
      resources:
        requests:
          cpu: 4000m
          memory: 8Gi
        limits:
          cpu: 4000m
          memory: 8Gi
    container-security:
      tes-consec-ui:
        resources:
          requests:
            memory: "3Gi"
            cpu: "2"
          limits:
            memory: "4Gi"
            cpu: "4"
      tes-consec-api:
        resources:
          requests:
            memory: "3Gi"
            cpu: "2"
          limits:
            memory: "6Gi"
            cpu: "4"
      tes-consec-scan:
        resources:
          requests:
            memory: "5Gi"
            cpu: "2"
          limits:
            memory: "10Gi"
            cpu: "4"
      tes-consec-policy:
        resources:
          requests:
            memory: "2Gi"
            cpu: "2"
          limits:
            memory: "6Gi"
            cpu: "4"
      tes-consec-tvdl:
        resources:
          requests:
            memory: "10Gi"
            cpu: "2"
          limits:
            memory: "15Gi"
            cpu: "4"
```

For sizing requirements specific to your needs, see [Tenable Enclave Security System Requirements](https://docs.tenable.com/enclave-security/Content/system-requirements.htm).

### Specify Service Annotations

If you are using Kubernetes in a hosted environment and your provider (for example, AWS) supports it, use the following annotation to restrict access to the created load balancer.

```yaml
tes:
  blades:
    securitycenter:
      service:
        annotations:
          service.beta.kubernetes.io/load-balancer-source-ranges: "<IP Range>"
```

### Restrict Access to LoadBalancer

If you are using Kubernetes in a hosted environment and your provider (for example, AWS) supports it, use the following annotation to restrict access to the created load balancer.

```yaml
tes:
  blades:
    securitycenter:
      service:
        loadBalancerSourceRanges:
        - <IP Range 1>
        - <IP Range 2>
```

### Specify Node Affinity

Tenable Enclave Security requires an amd64 node. If you are using Kubernetes in an environment with multiple available node types, or that requires a node affinity policy, you can add the policy to values.yaml. The following is an example policy for Karpenter in AWS and EKS.

```yaml
tes:
  blades:
    global:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
              - matchExpressions:
                - key: kubernetes.io/arch
                  operator: In
                  values:
                  - amd64
                - key: karpenter.sh/capacity-type
                  operator: In
                  values:
                    - on-demand
```

### Disable cert-manager CSI Driver

Tenable Enclave Security recommends using the cert-manager CSI driver for provisioning certificates used by its services for mTLS. However, if the CSI driver cannot be installed on your cluster, you can disable it by specifying the following configuration. This will use cert-manager certificate resources to provision certificates into a secret that will be consumed by respective services:

```yaml
tes:
  blades:
    global:
      disableCertManagerCsiDriver: true
```

### Specify PVC Size

Adjust persistent volume claim size for SecurityCenter:

```yaml
tes:
  blades:
    securitycenter:
      persistentVolumeClaim:
        size: 100Gi
```

### Specify PVC Storage Class

To use a StorageClass other than the default StorageClass for SecurityCenter.

```yaml
tes:
  blades:
    securitycenter:
      persistentVolumeClaim:
        storageClassName: fast-ssd
```

### Change TES Service Type

The below values can be used to specify a service type other than LoadBalancer (default).
Example to change TES service type from LoadBalancer to ClusterIP:

```yaml
tes:
  blades:
    securitycenter:
      service:
        type: ClusterIP
        annotations: ""
```

**Note:** If you change service type from LoadBalancer, you must [provide the URL for Tenable Enclave Security](#configure-routable-url).

### Configure Routable URL

You can configure the URL to access and route traffic to Tenable Enclave Security. This URL is used by the scanners to publish data to the Tenable Enclave Security instance.

**Note:**: If you do not configure a URL, Tenable Enclave Security automatically tries to use the LoadBalancer service tes ingress hostname/IP as the URL.

```yaml
tes:
  blades:
    global:
      url: tes.tenable.com
```

### External DNS Annotation

You can add an external DNS annotation to the Tenable Enclave Security service with the following options.

```yaml
tes:
  blades:
    securitycenter:
      service:
        # value specified in subdomain would be added to the extdns annotation
        # in the format:
        # external-dns.alpha.kubernetes.io/hostname: {{ .Release.Namespace -}}.{{ .Values.service.subdomain }}
        extDnsAnnotation:
          subdomain: "tenable.com"
          enabled: true
```

When applied to the `tenable-enclave-security` namespace, this results in:

```yaml
external-dns.alpha.kubernetes.io/hostname: tenable-enclave-security.tenable.com
```

## Global TES Settings

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| tes.blades.global.scopeCluster | bool | `true` | When set to `false`, disables cluster level roles. Use this when licensing by namespace ID. Default is `true` for backwards compatibility. |
| tes.blades.global.useCustomCA | bool | `false` | Use custom Certificate Authority for certificate management |
| tes.blades.global.customCAIssuerKind | string | `"Issuer"` | Kind of cert-manager issuer (Issuer or ClusterIssuer) |
| tes.blades.global.nodeSelector | object | `{}` | Node selector for pod scheduling |
| tes.blades.global.tolerations | list | `[]` | Tolerations for pod scheduling |
| tes.blades.global.affinity | object | `nil` | Affinity rules for pod scheduling. See example below for multi-arch clusters. |
| tes.blades.global.url | string | `nil` | Routable URL to access Tenable Enclave Security. Used by scanners to publish data. If not configured, automatically uses LoadBalancer service hostname. |
| tes.blades.global.registry | string | `"tenable"` | Container registry for TES blade images |
| tes.blades.global.disableCertManagerCsiDriver | bool | `false` | Disable cert-manager CSI driver and use certificate resources instead |


## Important Notes

⚠️ **Tenable Enclave Security does not support changing any values besides the ones listed in this documentation.**

## Additional Resources

- [Tenable Enclave Security Documentation](https://docs.tenable.com/enclave-security/)
- [System Requirements](https://docs.tenable.com/enclave-security/Content/system-requirements.htm)
- [GitHub Repository](https://github.com/tenable/helm-charts)
