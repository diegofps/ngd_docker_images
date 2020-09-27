FROM diegofpsouza/flask:0.0.1

WORKDIR /project

RUN apt update && apt install -yq openalpr openalpr-daemon openalpr-utils libopenalpr-dev python3-openalpr
RUN cp -a /usr/share/openalpr/runtime_data/ocr/tessdata/*.traineddata /usr/share/openalpr/runtime_data/ocr/

COPY src .

EXPOSE 4568

CMD ["flask", "run", "--host=0.0.0.0", "--port=4568", "--without-threads"]

