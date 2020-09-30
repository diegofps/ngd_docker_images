FROM diegofpsouza/flask:0.0.1

RUN apt update && apt install -yq tesseract-ocr tesseract-ocr-eng tesseract-ocr-por libtesseract-dev
RUN apt install -yq zlib1g-dev zlib1g libjpeg-dev
RUN pip3 install tesserwrap Pillow

WORKDIR /project

COPY src .

EXPOSE 4568

CMD ["flask", "run", "--host=0.0.0.0", "--port=4568", "--without-threads"]

