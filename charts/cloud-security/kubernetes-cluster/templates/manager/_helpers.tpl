{{- define "manager.globalResourceName" -}}
{{- print "tenable" "-" (include "manager.resourceNamePrefix" .root) "-" .name "-" (trunc 8 (sha256sum (print .root.Release.Namespace ":" .root.Release.Name))) }}
{{- end }}

{{- define "manager.labels" -}}
app.kubernetes.io/component: manager
{{- end }}

{{- define "manager.resourceNamePrefix" -}}
{{- print .Values.resourceNamePrefix "-manager" }}
{{- end }}