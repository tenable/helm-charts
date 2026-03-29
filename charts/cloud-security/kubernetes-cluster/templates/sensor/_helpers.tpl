{{- define "sensor.containerImage" -}}
{{- print .Values.containerImage.registry "/" .Values.sensor.containerImage.repository ":" (coalesce .Values.sensor.containerImage.tag .Values.containerImage.tag | default .Chart.AppVersion)}}
{{- end }}

{{- define "sensor.containerSecurityContext.enforced" -}}
{{- if .Values.sensor.runtimeDetection }}
{{- if semverCompare ">=1.30" .Capabilities.KubeVersion.Version }}
appArmorProfile:
  type: Unconfined
{{- end }}
capabilities:
  add:
    - DAC_OVERRIDE
    - DAC_READ_SEARCH
    - FOWNER
    - IPC_LOCK
    - NET_ADMIN
    - NET_RAW
    - PERFMON
    - SYS_ADMIN
    - SYS_CHROOT
    - SYS_PTRACE
    - SYS_RAWIO
    - SYS_RESOURCE
privileged: false
seLinuxOptions:
  user: system_u
  role: system_r
  level: "s0"
  type: super_t
{{- else }}
privileged: true
{{- end }}
runAsUser: 0
{{- end }}

{{- define "sensor.containerSecurityContext" -}}
{{- $additionalSecurityContext := default dict .additionalSecurityContext -}}
{{- $enforced := fromYaml (include "sensor.containerSecurityContext.enforced" .root) -}}
{{- $result := deepCopy $additionalSecurityContext -}}
{{- range $key, $value := $enforced }}
{{- $_ := set $result $key $value -}}
{{- end -}}
{{- toYaml $result }}
{{- end }}

{{ define "sensor.enabled" -}}
{{ if or .Values.sensor.enabled .Values.sensor.runtimeDetection .Values.sensor.vulnerabilityManagement -}}true{{ end -}}
{{- end }}

{{- define "sensor.globalResourceName" -}}
{{- print "tenable" "-" (include "sensor.resourceNamePrefix" .root) "-" .name "-" (trunc 8 (sha256sum (print .root.Release.Namespace ":" .root.Release.Name))) }}
{{- end }}

{{- define "sensor.labels" -}}
app.kubernetes.io/component: sensor
{{- end }}

{{- define "sensor.resourceNamePrefix" -}}
{{- print .Values.resourceNamePrefix "-sensor" }}
{{- end }}