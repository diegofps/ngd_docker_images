.PHONY: index facedetection tesseract openalpr telemetry monitor1

all: facedetection openalpr telemetry tesseract monitor1 index

index:
	mv *.tgz ../docs/repo/ 2> /dev/null || true
	helm repo index ../docs/repo/ --url https://diegofps.github.io/ngd_docker_images/repo

facedetection:
	helm package demo_ws_facedetection

openalpr:
	helm package demo_ws_openalpr

telemetry:
	helm package demo_ws_telemetry

tesseract:
	helm package demo_ws_tesseract

monitor1:
	helm package monitor1

