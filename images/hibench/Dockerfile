FROM diegofpsouza/bigdata2:0.0.1 as intermediate

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt update
RUN apt install openjdk-8-jre openjdk-8-jdk -yq
RUN apt install maven -yq

WORKDIR /src
COPY data .

RUN /src/install_hibench.sh

#########################################################

FROM diegofpsouza/bigdata2:0.0.1

ENV DEBIAN_FRONTEND="noninteractive"

RUN apt update
RUN apt install python2-minimal -yq
RUN rm -rf /var/cache/apt/*

COPY --from=intermediate /hibench /hibench
COPY --from=intermediate /root/.m2 /root/.m2
