FROM ubuntu:20.04 as intermediate
ENV DEBIAN_FRONTEND="noninteractive"
WORKDIR /spark_src
COPY data .
RUN /spark_src/install_spark.sh



FROM openjdk:11

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt update

COPY --from=intermediate /spark /spark
ENV PATH="$PATH:/spark/bin"
ENV SPARK_HOME="/spark"

RUN apt install vim -yq

WORKDIR /app
COPY src .

CMD ["/app/start.sh"]
