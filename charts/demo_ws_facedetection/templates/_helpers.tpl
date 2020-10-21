
{{- define "app" -}}
{{- printf "%s-facedetection-app" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "loadbalancer" -}}
{{- printf "%s-facedetection-loadbalancer" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "loadbalancerSvc" -}}
{{- printf "%s-facedetection-loadbalancer-svc" .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
