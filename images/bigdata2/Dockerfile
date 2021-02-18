FROM ubuntu:20.04 as intermediate
ENV DEBIAN_FRONTEND="noninteractive"
WORKDIR /src
COPY data .
RUN /src/install_hadoop.sh
RUN /src/install_spark.sh



FROM openjdk:11

ENV DEBIAN_FRONTEND="noninteractive"

COPY --from=intermediate /spark /spark
COPY --from=intermediate /hadoop /hadoop

RUN apt update
RUN apt install ssh pdsh vim -yq

ENV PATH="$PATH:/spark/bin:/hadoop/bin"
ENV HADOOP_HOME="/hadoop"
ENV SPARK_HOME="/spark"

WORKDIR /app
COPY src .

CMD ["/app/start.sh"]
