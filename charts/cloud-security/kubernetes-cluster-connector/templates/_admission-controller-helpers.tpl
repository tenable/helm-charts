{{- define "admissionController.annotations" -}}
meta.helm.sh/release-name: {{ .Release.Name }}
meta.helm.sh/release-namespace: {{ .Release.Namespace }}
{{- end }}

{{- define "admissionController.containerImagePath" -}}
{{ if contains ":" .Values.admissionController.containerImagePath }}
{{- print .Values.admissionController.containerImagePath }}
{{ else }}
{{- print .Values.admissionController.containerImagePath ":" .Chart.AppVersion }}
{{- end }}
{{- end }}

{{- define "admissionController.globalResourceName" -}}
{{- print "tenable" "-" .root.Values.admissionController.resourceNamePrefix "-" .name "-" (trunc 8 (sha256sum (print .root.Release.Namespace ":" .root.Release.Name))) }}
{{- end }}

{{- define "admissionController.labels" -}}
{{ include "admissionController.matchLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Chart.Version }}
{{- end }}

{{- define "admissionController.matchLabels" -}}
app.kubernetes.io/name: tenable-kubernetes-cluster-admission-controller
{{- end }}
