{{- define "annotations" -}}
meta.helm.sh/release-name: {{ .Release.Name }}
meta.helm.sh/release-namespace: {{ .Release.Namespace }}
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

{{- define "environmentVariables" -}}
env:
- name: SIL_LogFormat
  value: Text
{{- end }}

{{- define "imagePullSecretEnabled" -}}
    {{- if or (and .Values.admissionController.enabled (not .Values.admissionController.containerImagePullSecrets)) (and .Values.sensor.enabled (not .Values.sensor.containerImagePullSecrets)) }}
        {{- print "true"}}
    {{- else }}
        {{- print "false"}}
    {{- end }}
{{- end }}

{{- define "globalResourceName" -}}
{{- print "tenable" "-" .root.Values.resourceNamePrefix "-" .name "-" (trunc 8 (sha256sum (print .root.Release.Namespace ":" .root.Release.Name))) }}
{{- end }}

{{- define "labels" -}}
app.kubernetes.io/instance: {{ .Release.Name | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ .Chart.Name | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/version: {{ .Chart.Version }}
{{- end }}