{{- define "connector.globalResourceName" -}}
{{- print "tenable" "-" (include "connector.resourceNamePrefix" .root) "-" .name "-" (trunc 8 (sha256sum (print .root.Release.Namespace ":" .root.Release.Name))) }}
{{- end }}

{{- define "connector.labels" -}}
app.kubernetes.io/component: connector
{{- end }}

{{- define "connector.resourceNamePrefix" -}}
{{- print .Values.resourceNamePrefix "-connector" }}
{{- end }}