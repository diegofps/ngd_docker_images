FROM diegofpsouza/flask:0.0.1

RUN pip3 install pymongo pika flask-socketio flask-cors

WORKDIR /app

COPY src .

ENV FLASK_ENV=development

CMD ["flask", "run", "--host=0.0.0.0", "--port=8081"]
