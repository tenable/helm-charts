{{- define "annotations" -}}
meta.helm.sh/release-name: {{ .Release.Name }}
meta.helm.sh/release-namespace: {{ .Release.Namespace }}
{{- end }}

{{- define "apiKeyTokenSecret" -}}
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

{{- define "apiKeyTokenVolume" -}}
- name: {{ .name }}
  secret:
    secretName: {{ .name }}
    items:
    - key: API_KEY_TOKEN
      path: apikeytoken
{{- end }}

{{- define "containerImage" -}}
{{- print .Values.containerImage.registry "/" .Values.containerImage.repository ":" (.Values.containerImage.tag | default .Chart.AppVersion)}}
{{- end }}

{{- define "environmentVariables" -}}
env:
  - name: SIL_LogFormat
    value: Text
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

{{- define "containerImagePullSecret" -}}
{{- if and (not .root.Values.containerImage.pullSecrets) .root.Values.containerImage.registryUsername .root.Values.containerImage.registryPassword }}
{{- $dockerConfigJson := ( printf "{\"auths\": {\"%s\": { \"username\": \"%s\", \"password\": \"%s\", \"auth\": \"%s\"}}}" .root.Values.containerImage.registry .root.Values.containerImage.registryUsername .root.Values.containerImage.registryPassword (printf "%s:%s" .root.Values.containerImage.registryUsername .root.Values.containerImage.registryPassword | b64enc)) }}
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
data: 
  .dockerconfigjson: {{  $dockerConfigJson | b64enc | quote }}
type: kubernetes.io/dockerconfigjson
{{- end }}
{{- end }}
