FROM diegofpsouza/flask:0.0.1

RUN pip3 install pymongo pika flask-socketio flask-cors requests

WORKDIR /app

COPY src .

ENV FLASK_ENV=development

# If you change this port remember to change it in the code as well
CMD ["flask", "run", "--host=0.0.0.0", "--port=8081"]
