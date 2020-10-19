FROM diegofpsouza/pyarrow:0.0.1

RUN pip3 install pymongo pika

WORKDIR /app

COPY src .

CMD ["./main.py"]
