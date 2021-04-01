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

RUN apt update && apt install python2-minimal curl gnupg2 time libgomp1 htop tmux -yq && ln -s `which python2` /usr/bin/python
RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list
RUN curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add
RUN apt update && apt install sbt -yq
RUN rm -rf /var/cache/apt/*

COPY --from=intermediate /hibench /hibench
COPY --from=intermediate /root/.m2 /root/.m2
