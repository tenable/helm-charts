{{/*
Resolve the external domain for Host() matching and certificate SAN.
Priority:
  1. external-dns annotation on the tes Service (dev/test namespaces with a custom CNAME)
  2. tes-url in tes-config stripped of scheme (production — raw ELB hostname)
  3. .Values.global.domain (unit tests / manual installs)
  4. Default to <namespace>.local (NodePort/testing deployments without configured domain)
*/}}
{{- define "tes-traefik.domain" -}}
{{- $svc := lookup "v1" "Service" .Release.Namespace "tes" -}}
{{- $extDns := "" -}}
{{- if $svc -}}
{{- $extDns = index $svc.metadata.annotations "external-dns.alpha.kubernetes.io/hostname" | default "" -}}
{{- end -}}
{{- if $extDns -}}
{{- $extDns -}}
{{- else -}}
{{- $cmap := lookup "v1" "ConfigMap" .Release.Namespace "tes-config" -}}
{{- $tesUrl := "" -}}
{{- if $cmap -}}
{{- $tesUrl = index $cmap.data "tes-url" | default "" | trimPrefix "https://" | trimPrefix "http://" -}}
{{- end -}}
{{- if $tesUrl -}}
{{- $tesUrl -}}
{{- else if .Values.global.domain -}}
{{- .Values.global.domain -}}
{{- else -}}
{{- printf "%s.local" .Release.Namespace -}}
{{- end -}}
{{- end -}}
{{- end }}
