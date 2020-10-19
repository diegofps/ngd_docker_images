all:
	helm package demo_ws_facedetection demo_ws_openalpr demo_ws_telemetry demo_ws_tesseract monitor1
	mv *.tgz ../docs/repo/
	helm repo index ../docs/repo/ --url https://diegofps.github.io/ngd_docker_images/repo
