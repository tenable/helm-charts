{{- define "annotations" -}}
meta.helm.sh/release-name: {{ .Release.Name }}
meta.helm.sh/release-namespace: {{ .Release.Namespace }}
meta.helm.sh/service-endpoint: {{ .Values.serviceEndpoint }}
meta.helm.sh/service-id: {{ .Values.serviceId }}
{{- end }}

{{- define "apiKeyTokenSecret" -}}
  {{- if .root.Values.apiKeyToken }}
apiVersion: v1
kind: Secret
metadata:
  annotations:
    {{- include "annotations" .root | nindent 4 }}
    {{- with .annotations }}
      {{- join "\n" . | nindent 4 }}
    {{- end }}
  labels:
    {{- include "labels" .root | nindent 4 }}
  name: {{ .name }}
  namespace: {{ .root.Release.Namespace }}
stringData:
  API_KEY_TOKEN: {{ .root.Values.apiKeyToken }}
type: Opaque
  {{- end }}
{{- end }}

{{- define "apiKeyTokenVolume" -}}
- name: {{ .name }}
  secret:
{{- if .root.Values.apiKeyToken }}
    secretName: {{ .name }}
{{- else }}
  {{- if .root.Values.apiKeyTokenSecretName }}
    secretName: {{ .root.Values.apiKeyTokenSecretName }}
  {{- else }}
    {{ fail "Required: apiKeyToken -or- apiKeyTokenSecretName" }}
  {{- end }}
{{- end }}
    items:
    - key: API_KEY_TOKEN
      path: apikeytoken
{{- end }}

{{- define "containerImagePath" -}}
{{ if contains ":" .Values.containerImagePath }}
{{- print .Values.containerImagePath }}
{{ else }}
{{- print .Values.containerImagePath ":" .Chart.AppVersion }}
{{- end }}
{{- end }}

{{- define "labels" -}}
{{ include "matchLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/version: {{ .Chart.Version }}
{{- end }}

{{- define "matchLabels" -}}
app.kubernetes.io/instance: {{ .Release.Name | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/name: {{ .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}