FROM ubuntu:20.04 as intermediate
ENV DEBIAN_FRONTEND="noninteractive"
WORKDIR /hadoop_src
COPY data .
RUN /hadoop_src/install_hadoop.sh hadoop-master



FROM openjdk:11

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt update
RUN apt install ssh pdsh -yq

COPY --from=intermediate /hadoop /hadoop
ENV PATH="$PATH:/hadoop/bin"
ENV HADOOP_HOME="/hadoop"

RUN apt install vim -yq

WORKDIR /app
COPY src .

CMD ["/app/start.sh"]
