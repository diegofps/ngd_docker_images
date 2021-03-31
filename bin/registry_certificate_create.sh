#!/bin/sh

HOST_IP=`hostname -I | awk '{ print $1 }'`
TGT="subjectAltName = IP:${HOST_IP}"

if [ `sudo cat /etc/ssl/openssl.cnf | grep "$TGT"` = "" ]
then
  echo "Adding this machine as a subjectAltName"
  sudo cat /etc/ssl/openssl.cnf | sed "s/\[ v3_ca \]/[ v3_ca ]\n$TGT/" > ./tmp
  mv ./tmp /etc/ssl/openssl.cnf
else
  echo "This machine is already a subjectAltName"
fi

echo "Creating certificate"
mkdir -p ~/.certs
sudo openssl req -newkey rsa:4096 -nodes -keyout ~/.certs/registry.key \
    -x509 -days 365 -out ~/.certs/registry.crt \
    -addext "subjectAltName = IP:$HOST_IP" \
    -subj '/C=BR/ST=RJ/L=Rio de Janeiro/O=Wespa/CN=host.local/'

echo "Done!"

