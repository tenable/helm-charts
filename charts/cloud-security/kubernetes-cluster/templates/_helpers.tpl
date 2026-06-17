{{- define "annotations" -}}
meta.helm.sh/release-name: {{ .Release.Name }}
meta.helm.sh/release-namespace: {{ .Release.Namespace }}
{{- end }}

{{- define "apiKeyTokenFilePath" -}}
{{ print (.Values.containerSecrets.volumeMountPath) "/apikeytoken" }}
{{- end }}

{{- define "apiKeyTokenSecret" -}}
{{- if and (not .root.Values.containerSecrets.injectExternally) (not .root.Values.containerSecrets.apiKeyTokenName) }}
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
  namespace: {{ include "namespace" .root }}
stringData:
  API_KEY_TOKEN: {{ .root.Values.apiKeyToken }}
type: Opaque
{{- end }}
{{- end }}

{{- define "apiKeyTokenSecretName" -}}
{{- if .root.Values.containerSecrets.apiKeyTokenName -}}
{{- .root.Values.containerSecrets.apiKeyTokenName -}}
{{- else if .parent -}}
{{- print .root.Values.resourceNamePrefix "-" .parent "-secret" -}}
{{- else -}}
{{- print .root.Values.resourceNamePrefix "-secret" -}}
{{- end -}}
{{- end }}

{{- define "containerCaCertificateEnabled" -}}
{{- if or .Values.containerCaCertificate.pem .Values.containerCaCertificate.secretName -}}true{{- end }}
{{- end }}

{{- define "containerCaCertificateEnvironmentVariables" -}}
{{- if include "containerCaCertificateEnabled" . }}
- name: SSL_CERT_DIR
  value: {{ printf "/etc/ssl/certs:%s" .Values.containerCaCertificate.volumeMountPath | quote }}
{{- end }}
{{- end }}

{{- define "containerCaCertificateSecret" -}}
{{- if .root.Values.containerCaCertificate.pem }}
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
  namespace: {{ include "namespace" .root }}
stringData:
  ca.crt: {{ .root.Values.containerCaCertificate.pem | quote }}
type: Opaque
{{- end }}
{{- end }}

{{- define "containerCaCertificateSecretName" -}}
{{- if .root.Values.containerCaCertificate.secretName -}}
{{- .root.Values.containerCaCertificate.secretName -}}
{{- else if .parent -}}
{{- print .root.Values.resourceNamePrefix "-" .parent "-ca-certificate" -}}
{{- else -}}
{{- print .root.Values.resourceNamePrefix "-ca-certificate" -}}
{{- end -}}
{{- end }}

{{- define "containerCaCertificateVolume" -}}
{{- if include "containerCaCertificateEnabled" .root }}
- name: {{ print .root.Values.resourceNamePrefix "-ca-certificate" }}
  secret:
    secretName: {{ .name | default (include "containerCaCertificateSecretName" (dict "root" .root)) | quote }}
{{- end }}
{{- end }}

{{- define "containerCaCertificateVolumeMount" -}}
{{- if include "containerCaCertificateEnabled" . }}
- mountPath: {{ .Values.containerCaCertificate.volumeMountPath | quote }}
  name: {{ print .Values.resourceNamePrefix "-ca-certificate" }}
  readOnly: true
{{- end }}
{{- end }}

{{- define "containerEnvironmentVariables" -}}
env:
{{- with .Values.containerEnvironmentVariables }}
{{- toYaml . | nindent 2 }}
{{- end }}
  - name: SIL_LogFormat
    value: Text
{{- include "containerCaCertificateEnvironmentVariables" . | nindent 2 }}
{{- end }}

{{- define "containerImage" -}}
{{- print .Values.containerImage.registry "/" .Values.containerImage.repository ":" (.Values.containerImage.tag | default .Chart.AppVersion)}}
{{- end }}

{{- define "containerImagePullSecret" -}}
{{- if and (not .root.Values.containerImage.pullSecrets) .root.Values.containerImage.registryUsername .root.Values.containerImage.registryPassword -}}
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
  namespace: {{ include "namespace" .root }}
data:
  .dockerconfigjson: {{  $dockerConfigJson | b64enc | quote }}
type: kubernetes.io/dockerconfigjson
{{- end }}
{{- end }}

{{- define "containerImagePullSecretNames" -}}
{{- if .root.Values.containerImage.pullSecrets }}
  {{- toYaml .root.Values.containerImage.pullSecrets | nindent 0 }}
{{- else -}}
    {{- if and .root.Values.containerImage.registryUsername .root.Values.containerImage.registryPassword -}}
- name: {{ .name | default (print .root.Values.resourceNamePrefix "-image-pull-secret") }}
    {{- end }}
{{- end }}
{{- end }}


{{- define "containerSecretsVolume" -}}
{{- if not .root.Values.containerSecrets.injectExternally -}}
- name: {{ print .root.Values.resourceNamePrefix "-secret" }}
  secret:
    items:
    - key: API_KEY_TOKEN
      path: apikeytoken
    secretName: {{ .name | default (include "apiKeyTokenSecretName" (dict "root" .root)) | quote }}
{{- end }}
{{- end }}

{{- define "containerSecretsVolumeMount" -}}
{{- if not .Values.containerSecrets.injectExternally -}}
- mountPath: {{ .Values.containerSecrets.volumeMountPath | quote }}
  name: {{ print .Values.resourceNamePrefix "-secret" }}
  readOnly: true
{{- end }}
{{- end }}

{{- define "containerSecurityContext" -}}
{{- $defaults := fromYaml (include "containerSecurityContext.defaults" .) -}}
{{- $securityContext := default dict .securityContext -}}
{{- $result := deepCopy $defaults -}}
{{- range $key, $value := $securityContext }}
{{- $_ := set $result $key $value -}}
{{- end -}}
{{- toYaml $result }}
{{- end }}

{{- define "containerSecurityContext.defaults" -}}
allowPrivilegeEscalation: false
capabilities:
  drop:
    - ALL
runAsNonRoot: true
runAsUser: 1000
{{- end }}

{{- define "globalResourceName" -}}
{{- print "tenable" "-" .root.Values.resourceNamePrefix "-" .name "-" (trunc 8 (sha256sum (print .root.Release.Namespace ":" .root.Release.Name))) }}
{{- end }}

{{- define "labels" -}}
app.kubernetes.io/instance: {{ .Release.Name | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/name: {{ .Chart.Name | trunc 63 | trimSuffix "-" }}
app.kubernetes.io/version: {{ .Chart.Version }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "namespace" -}}
{{- .Values.namespaceOverride | default .Release.Namespace }}
{{- end }}

{{- define "podSecurityContext" -}}
{{- $defaults := fromYaml (include "podSecurityContext.defaults" .) -}}
{{- $globalContext := default dict .root.Values.pod.securityContext -}}
{{- $workloadContext := default dict .workloadContext -}}
{{- $result := deepCopy $defaults -}}
{{- range $key, $value := $globalContext }}
{{- $_ := set $result $key $value -}}
{{- end -}}
{{- range $key, $value := $workloadContext }}
{{- $_ := set $result $key $value -}}
{{- end -}}
{{- toYaml $result }}
{{- end }}

{{- define "podSecurityContext.defaults" -}}
seccompProfile:
  type: RuntimeDefault
{{- end }}