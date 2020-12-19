FROM ubuntu:18.04

ENV DEBIAN_FRONTEND="noninteractive"
ENV LANGUAGE="en_US.UTF-8"
ENV LC_ALL="en_US.UTF-8"
ENV LANG="en_US.UTF-8"

WORKDIR /project

RUN apt update && apt install software-properties-common -yq
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
RUN add-apt-repository 'deb [arch=amd64,arm64,ppc64el] http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.5/ubuntu bionic main' & apt update
RUN apt install -yq mariadb-server galera-4 mariadb-client libmariadb3 mariadb-backup mariadb-common

EXPOSE 3306
EXPOSE 4567
EXPOSE 4568
EXPOSE 4444

COPY data/galera.cnf /etc/mysql/mariadb.conf.d/60-galera.cnf
COPY src .

CMD [ "bash", "/project/run.sh" ]
