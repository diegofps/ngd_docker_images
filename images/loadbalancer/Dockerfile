FROM diegofpsouza/flask:0.0.1

ENV CLIENT_CRT="/keys/client-admin.crt"
ENV CLIENT_KEY="/keys/client-admin.key"
ENV SERVER_CRT="/keys/server-ca.crt"

RUN pip3 install jsonpickle requests

WORKDIR /project

COPY src .

EXPOSE 4570

CMD ["flask", "run", "--host=0.0.0.0", "--port=4570"]
