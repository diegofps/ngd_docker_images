FROM diegofpsouza/openalpr:0.0.1

WORKDIR /project

RUN pip3 install flask gunicorn

COPY src .

EXPOSE 4568

#CMD ["flask", "run", "--host=0.0.0.0", "--port=4568", "--without-threads"]
CMD ["bash", "/project/run.sh"]
