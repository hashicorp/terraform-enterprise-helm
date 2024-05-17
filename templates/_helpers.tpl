{{/*
Expand the name of the chart.
*/}}
{{- define "k8s.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "k8s.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "k8s.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "cacert.path" -}}
{{ .Values.tls.caCertBaseDir }}/{{ .Values.tls.caCertFileName }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "k8s.labels" -}}
helm.sh/chart: {{ include "k8s.chart" . }}
{{ include "k8s.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "k8s.selectorLabels" -}}
app.kubernetes.io/name: {{ include "k8s.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "k8s.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "k8s.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Prints the key-value pair from the 'env.variables' entry in the Values file.
*/}}
{{- define "helpers.list-env-variables"}}
{{- range $key, $val := .Values.env.variables }}
{{ $key }}: {{ $val | quote }}
{{- end }}
{{- end }}

{{/*
Prints the key-value pair from the 'env.secrets' entry in the Values file
and base64 encodes the value.
*/}}
{{- define "helpers.list-env-secrets" }}
{{- range $key, $val := .Values.env.secrets }}
{{ $key }}: {{ trim $val | b64enc }}
{{- end }}
{{- end }}

{{/*
Prints the file contents of the environment secrets file
and base64 encodes the value from the key-value pair.
*/}}
{{- define "helpers.enc-b64-secrets-file" }}
{{- range .Files.Lines .Values.env.secretsFilePath }}
{{- $kv := splitList ":" . -}}
{{- $k := first $kv -}}
{{- if and ($k) (eq (hasPrefix "#" $k) false)  }}
{{ $k }}: {{ trim (last $kv) | b64enc }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Generates a SHA-256 sum of concatenated env vars ConfigMap contents and env secrets.
*/}}
{{- define "helpers.env-checksum" }}
{{- $env_vars := include (print $.Template.BasePath "/config-map.yaml") . -}}
{{- if .Values.env.secretsFilePath }}
{{- $env_secrets := print "%s%s" (include "helpers.list-env-secrets" .) (include "helpers.enc-b64-secrets-file" .) -}}
{{- print "%s%s" $env_vars $env_secrets | sha256sum }}
{{- else }}
{{- $env_secrets := include "helpers.list-env-secrets" . -}}
{{- print "%s%s" $env_vars $env_secrets | sha256sum }}
{{- end }}
{{- end }}
