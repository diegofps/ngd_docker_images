FROM diegofpsouza/flask:0.0.1

RUN apt update && apt install -yq sysstat

RUN pip3 install jsonpickle

WORKDIR /project

COPY src .

EXPOSE 4580

CMD ["flask", "run", "--host=0.0.0.0", "--port=4580"]
