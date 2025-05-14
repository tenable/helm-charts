{{/*
Expand the name of the chart.
*/}}
{{- define "tes-operator.name" -}}
{{- default .Chart.Name .Values.operator.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "tes-operator.fullname" -}}
{{- if .Values.operator.fullnameOverride }}
{{- .Values.operator.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.operator.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "tes-operator.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "tes-operator.labels" -}}
helm.sh/chart: {{ include "tes-operator.chart" . }}
{{ include "tes-operator.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "tes-operator.selectorLabels" -}}
app.kubernetes.io/name: {{ include "tes-operator.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "tes-operator.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "tes-operator.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "tes-operator-secrets" -}}
{{- $cmap := lookup "v1" "Secret" .Release.Namespace "tes-operator-secrets" -}}
{{- if $cmap -}}
{{/*
   Reusing existing configmap data
*/}}
  helm_username: "{{ .Values.operator.helm.username | b64enc }}"
  helm_password: "{{ .Values.operator.helm.password | b64enc }}"
  installed_version: "{{ $cmap.data.installed_version }}"
  user_values: "{{ $cmap.data.user_values | default "" }}"
{{- else -}}
{{/*
    Generate new data
*/}}
  installed_version: ""
  helm_username: {{ .Values.operator.helm.username | b64enc | quote }}
  helm_password: {{ .Values.operator.helm.password | b64enc | quote }}
  installed_version: ""
  user_values: ""
{{- end -}}
{{- end -}}

{{- define "tes-operator-configmap" -}}
{{- $cmap := lookup "v1" "ConfigMap" .Release.Namespace "tes-operator-config" -}}
{{- if $cmap -}}
{{/* Reusing existing configmap data */}}
  version: "{{ .Values.tes.version }}"
  registry: "{{ .Values.operator.image.registry }}"
  helm_repository: "{{ .Values.operator.helm.repo }}"
  namespace: "{{ $cmap.data.namespace }}"
  image_pull_secret: "{{ .Values.operator.image.imagePullSecret }}"
  deploy_trigger: "{{ $cmap.data.deploy_trigger }}"
  user_values: {{ sha256sum (toJson .Values) }}
  tes_url: "{{ .Values.tes.blades.global.url }}"
{{- else -}}
{{/*
    Generate new data
*/}}
  version: "{{ .Values.tes.version }}"
  registry: "{{ .Values.operator.image.registry }}"
  helm_repository: "{{ .Values.operator.helm.repo }}"
  namespace: "{{ .Release.Namespace }}"
  image_pull_secret: "{{ .Values.operator.image.imagePullSecret }}"
  deploy_trigger: "1"
  user_values: {{ sha256sum (toJson .Values) }}
  tes_url: "{{ .Values.tes.blades.global.url }}"
  scope_cluster: "{{ .Values.tes.blades.global.scopeCluster | default true }}"
{{- end -}}
{{- end -}}
