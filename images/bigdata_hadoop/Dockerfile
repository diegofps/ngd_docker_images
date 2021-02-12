FROM ubuntu:20.04 as intermediate
ENV DEBIAN_FRONTEND="noninteractive"
WORKDIR /hadoop_src
COPY data .
RUN /hadoop_src/install_hadoop.sh



FROM openjdk:11

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt update
RUN apt install ssh pdsh -yq

COPY --from=intermediate /hadoop /hadoop
ENV PATH="$PATH:/hadoop/bin"
ENV HADOOP_HOME="/hadoop"

WORKDIR /app
COPY src .

RUN apt install vim -yq

CMD ["/app/start.sh"]
