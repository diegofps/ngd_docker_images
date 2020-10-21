
{{- define "app" -}}
{{- printf "%s-tesseract-app" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "loadbalancer" -}}
{{- printf "%s-tesseract-loadbalancer" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "loadbalancerSvc" -}}
{{- printf "%s-tesseract-loadbalancer-svc" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
