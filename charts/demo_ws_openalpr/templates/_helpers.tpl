
{{- define "app" -}}
{{- printf "%s-openalpr-app" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "loadbalancer" -}}
{{- printf "%s-openalpr-loadbalancer" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "loadbalancerSvc" -}}
{{- printf "%s-openalpr-loadbalancer-svc" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
