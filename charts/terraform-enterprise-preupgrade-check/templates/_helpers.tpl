{{/*
Chart name, truncated to 63 chars.
*/}}
{{- define "preupgrade-check.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Fully qualified app name. Uses release name + chart name, truncated to 63 chars.
If release name contains chart name, it won't be duplicated.
*/}}
{{- define "preupgrade-check.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Chart label value.
*/}}
{{- define "preupgrade-check.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "preupgrade-check.labels" -}}
helm.sh/chart: {{ include "preupgrade-check.chart" . }}
{{ include "preupgrade-check.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.image.tag | default .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "preupgrade-check.selectorLabels" -}}
app.kubernetes.io/name: {{ include "preupgrade-check.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Container image reference.
*/}}
{{- define "preupgrade-check.image" -}}
{{- $tag := .Values.image.tag | default .Chart.AppVersion -}}
{{- printf "%s:%s" .Values.image.repository $tag -}}
{{- end }}

{{/*
ServiceAccount name. Returns the created SA name, an explicit name, or "default".
*/}}
{{- define "preupgrade-check.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "preupgrade-check.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
TLS Secret name. Returns the existing certSecret name or the chart-created one.
*/}}
{{- define "preupgrade-check.tlsSecretName" -}}
{{- if .Values.tls.certSecret }}
{{- .Values.tls.certSecret }}
{{- else }}
{{- printf "%s-tls" (include "preupgrade-check.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Whether TLS volumes should be mounted.
True if certSecret is set OR inline cert+key are provided.
*/}}
{{- define "preupgrade-check.tlsEnabled" -}}
{{- if or .Values.tls.certSecret (and .Values.tls.cert .Values.tls.key) -}}
true
{{- end -}}
{{- end }}

{{/*
Strip surrounding quotes (single or double) from a string value.
Only strips if the first and last characters are matching quotes.
Uses trimPrefix/trimSuffix instead of substr/sub to avoid int64 type mismatch.
*/}}
{{- define "preupgrade-check.unquote" -}}
{{- $s := . -}}
{{- if and (ge (len $s) 2) (hasPrefix "\"" $s) (hasSuffix "\"" $s) -}}
  {{- trimPrefix "\"" (trimSuffix "\"" $s) -}}
{{- else if and (ge (len $s) 2) (hasPrefix "'" $s) (hasSuffix "'" $s) -}}
  {{- trimPrefix "'" (trimSuffix "'" $s) -}}
{{- else -}}
  {{- $s -}}
{{- end -}}
{{- end }}
