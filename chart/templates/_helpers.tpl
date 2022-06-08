{{- define "commonLabels" }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
helm.sh/chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
{{- end }}

{{- define "image" -}}
{{- $image := .Values.image -}}
{{- $registryName := $image.registry -}}
{{- $repositoryName := $image.repository -}}
{{- $tag := $image.tag | toString -}}
{{- if $registryName }}
{{- printf "%s/%s:%s" $registryName $repositoryName $tag -}}
{{- else -}}
{{- printf "%s:%s" $repositoryName $tag -}}
{{- end -}}
{{- end -}}

{{- define "getFrontTlsSecretName" -}}
{{- if .Values.frontendTlsSecretName -}}
{{- .Values.frontendTlsSecretName -}}
{{- else -}}
{{- print .Release.Name "-frontend-tls" -}}
{{- end -}}
{{- end -}}

