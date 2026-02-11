{{- define "sensor.containerImage" -}}
{{- print .Values.containerImage.registry "/" .Values.sensor.containerImage.repository ":" (coalesce .Values.sensor.containerImage.tag .Values.containerImage.tag | default .Chart.AppVersion)}}
{{- end }}

{{- define "sensor.containerSecurityContext.enforced" -}}
allowPrivilegeEscalation: true
privileged: true
runAsNonRoot: false
runAsUser: 0
{{- end }}

{{- define "sensor.containerSecurityContext" -}}
{{- $securityContext := default dict .securityContext -}}
{{- $enforced := fromYaml (include "sensor.containerSecurityContext.enforced" .) -}}
{{- $result := deepCopy $securityContext -}}
{{- range $key, $value := $enforced }}
{{- $_ := set $result $key $value -}}
{{- end -}}
{{- toYaml $result }}
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