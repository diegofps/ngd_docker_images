#!/usr/bin/sh

gunicorn -w=`nproc` --threads=1 --bind=0.0.0.0:4568 app:app
#flask run --host=0.0.0.0 --port=4568 --without-threads