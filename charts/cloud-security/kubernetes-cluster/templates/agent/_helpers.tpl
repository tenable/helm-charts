{{- define "agent.globalResourceName" -}}
{{- print "tenable" "-" (include "agent.resourceNamePrefix" .root) "-" .name "-" (trunc 8 (sha256sum (print .root.Release.Namespace ":" .root.Release.Name))) }}
{{- end }}

{{- define "agent.labels" -}}
app.kubernetes.io/component: agent
{{- end }}

{{- define "agent.resourceNamePrefix" -}}
{{- print .Values.resourceNamePrefix "-agent" }}
{{- end }}