{{- define "updater.globalResourceName" -}}
{{- print "tenable" "-" (include "updater.resourceNamePrefix" .root) "-" .name "-" (trunc 8 (sha256sum (print .root.Release.Namespace ":" .root.Release.Name))) }}
{{- end }}

{{- define "updater.labels" -}}
app.kubernetes.io/component: updater
{{- end }}

{{- define "updater.resourceNamePrefix" -}}
{{- print .Values.resourceNamePrefix "-updater" }}
{{- end }}