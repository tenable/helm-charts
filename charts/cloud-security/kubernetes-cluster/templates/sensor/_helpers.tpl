{{- define "sensor.containerImage" -}}
{{- print .Values.containerImage.registry "/" .Values.sensor.containerImage.repository ":" (coalesce .Values.sensor.containerImage.tag .Values.containerImage.tag | default .Chart.AppVersion)}}
{{- end }}

{{- define "sensor.globalResourceName" -}}
{{- print "tenable" "-" (include "sensor.resourceNamePrefix" .root) "-" .name "-" (trunc 8 (sha256sum (print .root.Release.Namespace ":" .root.Release.Name))) }}
{{- end }}

{{- define "sensor.labels" -}}
app.kubernetes.io/component: sensor
{{- end }}

{{- define "sensor.resourceNamePrefix" -}}
{{- print .Values.resourceNamePrefix "-sensor" }}
{{- end }}