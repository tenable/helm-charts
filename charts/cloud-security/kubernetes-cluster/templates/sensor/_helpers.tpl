{{- define "sensor.globalResourceName" -}}
{{- print "tenable" "-" (include "sensor.resourceNamePrefix" .root) "-" .name "-" (trunc 8 (sha256sum (print .root.Release.Namespace ":" .root.Release.Name))) }}
{{- end }}

{{- define "sensor.labels" -}}
app.kubernetes.io/component: sensor
{{- end }}

{{- define "sensor.resourceNamePrefix" -}}
{{- print .Values.resourceNamePrefix "-sensor" }}
{{- end }}