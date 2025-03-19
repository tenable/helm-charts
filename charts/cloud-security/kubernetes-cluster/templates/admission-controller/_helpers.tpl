{{- define "admissionController.containerImage" -}}
{{- print .Values.containerImage.registry "/" .Values.admissionController.containerImage.repository ":" (coalesce .Values.admissionController.containerImage.tag .Values.containerImage.tag | default .Chart.AppVersion)}}
{{- end }}

{{- define "admissionController.globalResourceName" -}}
{{- print "tenable" "-" (include "admissionController.resourceNamePrefix" .root) "-" .name "-" (trunc 8 (sha256sum (print .root.Release.Namespace ":" .root.Release.Name))) }}
{{- end }}

{{- define "admissionController.labels" -}}
app.kubernetes.io/component: admission-controller
{{- end }}

{{- define "admissionController.resourceNamePrefix" -}}
{{- print .Values.resourceNamePrefix "-admission-controller" }}
{{- end }}

{{- define "admissionController.tls" -}}
{{- if .Values.admissionController.tls }}
{{- .Values.admissionController.tls | toYaml }}
{{ else }}
{{- $serverCertificateAuthorityCertificate := genCA (printf "%s-ca" (include "admissionController.resourceNamePrefix" .)) 1095 -}}
{{- $serverCertificateHostname := (printf "%s-service.%s.svc" (include "admissionController.resourceNamePrefix" .) .Release.Namespace) }}
{{- $serverCertificate := genSignedCert $serverCertificateHostname nil (list $serverCertificateHostname) 1095 $serverCertificateAuthorityCertificate -}}
serverCertificateBase64: {{ $serverCertificate.Cert | b64enc }}
serverCertificateAuthorityCertificateBase64: {{ $serverCertificateAuthorityCertificate.Cert | b64enc }}
serverCertificateKeyBase64: {{ $serverCertificate.Key | b64enc }}
{{- end }}
{{- end }}