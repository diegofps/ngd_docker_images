FROM diegofpsouza/flask:0.0.1

RUN apt update && apt install -yq libopencv-dev python3-opencv python3 python3-dev clang python3-pip

WORKDIR /libfacedetection

COPY libfacedetection .

RUN ./build.sh lib && ./build.sh deploy

RUN pip3 install gunicorn

ENV PYTHONPATH="/libfacedetection"

WORKDIR /project

COPY src .

EXPOSE 4568

#CMD ["flask", "run", "--host=0.0.0.0", "--port=4568", "--without-threads"]
CMD ["bash", "/project/run.sh"]
