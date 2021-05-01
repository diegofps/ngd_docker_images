FROM ubuntu:20.04 as intermediate

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt update
RUN apt install openjdk-8-jre openjdk-8-jdk -yq

WORKDIR /src
COPY data .

RUN /src/install_hadoop.sh hadoop-primary
RUN /src/install_spark.sh

#########################################################

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt update
RUN apt install openjdk-8-jre openjdk-8-jdk -yq
RUN apt install ssh pdsh vim lsof -yq
RUN rm -rf /var/cache/apt/*

COPY --from=intermediate /spark /spark
COPY --from=intermediate /hadoop /hadoop
COPY --from=intermediate /hadoop_data /hadoop_data

RUN ln -s "/usr/lib/jvm/$(ls /usr/lib/jvm/ | grep java-8-openjdk)" /usr/lib/jvm/default-java
ENV JAVA_HOME="/usr/lib/jvm/default-java"

ENV PATH="$PATH:/spark/bin:/hadoop/bin"
ENV HADOOP_HOME="/hadoop"
ENV SPARK_HOME="/spark"

WORKDIR /app
COPY src .

CMD ["/app/start.sh"]
