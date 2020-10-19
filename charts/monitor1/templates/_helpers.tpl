{{/*
CONFIGMAPS
*/}}

{{- define "configNginx" -}}
{{- printf "%s-monitor1-config-nginx" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}



{{/*
PODS
*/}}

{{- define "cron" -}}
{{- printf "%s-monitor1-cron" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "monitor" -}}
{{- printf "%s-monitor1-monitor" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "backend" -}}
{{- printf "%s-monitor1-backend" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "frontend" -}}
{{- printf "%s-monitor1-frontend" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "mongo" -}}
{{- printf "%s-monitor1-mongo" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "nginx" -}}
{{- printf "%s-monitor1-nginx" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "rabbit" -}}
{{- printf "%s-monitor1-rabbit" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}



{{/*
SERVICE NAMES
*/}}

{{- define "backendSvcName" -}}
{{- printf "%s-monitor1-backend-svc" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "frontendSvcName" -}}
{{- printf "%s-monitor1-frontend-svc" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "mongoSvcName" -}}
{{- printf "%s-monitor1-mongo-svc" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "nginxSvcName" -}}
{{- printf "%s-monitor1-nginx-svc" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "rabbitSvcName" -}}
{{- printf "%s-monitor1-rabbit-svc" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}




{{/*
SERVICES
*/}}

{{- define "backendSvc" -}}
{{ include "backendSvcName" . }}.{{ .Values.namespace }}.svc.cluster.local
{{- end }}

{{- define "frontendSvc" -}}
{{ include "frontendSvcName" . }}.{{ .Values.namespace }}.svc.cluster.local
{{- end }}

{{- define "mongoSvc" -}}
{{ include "mongoSvcName" . }}.{{ .Values.namespace }}.svc.cluster.local
{{- end }}

{{- define "nginxSvc" -}}
{{ include "nginxSvcName" . }}.{{ .Values.namespace }}.svc.cluster.local
{{- end }}

{{- define "rabbitSvc" -}}
{{ include "rabbitSvcName" . }}.{{ .Values.namespace }}.svc.cluster.local
{{- end }}



