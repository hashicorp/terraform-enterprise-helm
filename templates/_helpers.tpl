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
Define helper to conditionally add securityContext to agentWorkerPodTemplate.
It does not output anything if agentWorkerPodTemplate is empty and OpenShift is not enabled.
*/}}
{{- define "k8s.addSecurityContext" -}}
{{- if or .Values.agentWorkerPodTemplate .Values.openshift.enabled }}
  {{- $defaultSecurityContext := dict "seccompProfile" (dict "type" "RuntimeDefault") "allowPrivilegeEscalation" false "capabilities" (dict "drop" (list "ALL")) "runAsNonRoot" true }}
  {{- if and .Values.openshift.enabled (not (hasKey .Values.agentWorkerPodTemplate "securityContext")) }}
    {{- $securityContextAdded := set .Values.agentWorkerPodTemplate "securityContext" $defaultSecurityContext }}
    {{- $securityContextAdded | toJson | b64enc }}
  {{- else }}
    {{- .Values.agentWorkerPodTemplate | toJson | b64enc }}
  {{- end }}
{{- end }}
{{- end }}

{{/*
Obtains the agent namespace as configured
*/}}
{{- define "helpers.agent-namespace"}}
{{- if .Values.agents.namespace.name }}
{{- .Values.agents.namespace.name }}
{{- else }}
{{- .Release.Namespace }}-agents
{{- end }}
{{- end }}

{{/*
Prints the key-value pairs from the 'env.secretKeyRefs' and 'env.configMapKeyRefs'
entries as `valueFrom` environment variables in the Values file.
*/}}
{{- define "helpers.list-valueFrom-variables"}}
{{- range $val := .Values.env.secretKeyRefs }}
- name: {{ $val.name }}
  valueFrom:
    secretKeyRef:
      name: {{ $val.secretName }}
      key: {{ $val.key }}
{{- end }}
{{- range $val := .Values.env.configMapKeyRefs }}
- name: {{ $val.name }}
  valueFrom:
    configMapKeyRef:
      name: {{ $val.configMapName }}
      key: {{ $val.key }}
{{- end }}
{{- end }}
