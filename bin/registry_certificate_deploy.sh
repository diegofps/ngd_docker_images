#!/bin/sh

if [ `whoami` = 'root' ]
then
  echo "You should not run this script as root, aborting"
  exit 0
fi

if [ ! -e "/home/$USER/.certs/registry.crt" -o ! -e "/home/$USER/.certs/registry.key" ]
then
  echo "You must create the certificates first. Did you execute registry_certificate_create.sh ?"
  exit 0
fi

HOST_IP=`hostname -I | awk '{ print $1 }'`
NODES=`ifconfig | grep tap | sed 's/tap\([0-9]\+\).\+/node\1/'`

deploy_certificate_to_node()
{
  NODE=$1

  # Send the certificate files
  ssh $NODE "mkdir -p /home/$USER/.certs && sudo rm -f /home/$USER/.certs/registry.*"
  scp "/home/$USER/.certs/registry.crt" "/home/$USER/.certs/registry.key" "$NODE:/home/$USER/.certs/"

  # Register in docker
  ssh $NODE "sudo mkdir -p /etc/docker/certs.d/$HOST_IP:27443"
  ssh $NODE "sudo cp /home/$USER/.certs/registry.crt /etc/docker/certs.d/$HOST_IP:27443/ca.crt"

  # register in ubuntu
  ssh $NODE "sudo cp /home/$USER/.certs/registry.crt /usr/local/share/ca-certificates/$HOST_IP:27443.crt"
  ssh $NODE "sudo update-ca-certificates"

  # Register in k3s
  scp "/etc/rancher/k3s/registries.yaml" "$NODE:/home/$USER/"
  ssh $NODE "sudo mkdir -p /etc/rancher/k3s/ && sudo mv /home/$USER/registries.yaml /etc/rancher/k3s/registries.yaml"
  ssh $NODE "sudo service k3s-agent restart"

  # Protect the file
  ssh $NODE "sudo chmod 600 /home/$USER/.certs/registry.key"

  echo "Deploy for $NODE complete"
}

deploy_certificate_to_host()
{
  echo "Deploying to host"

  # Register Docker
  sudo mkdir -p /etc/docker/certs.d/$HOST_IP:27443
  sudo cp ~/.certs/registry.crt /etc/docker/certs.d/$HOST_IP:27443/ca.crt

  # Register in ubuntu
  sudo cp ~/.certs/registry.crt "/usr/local/share/ca-certificates/$HOST_IP:27443.crt"
  sudo update-ca-certificates

  # Register in k3s
  sudo mkdir -p /etc/rancher/k3s/
  sudo bash -c "cat > /etc/rancher/k3s/registries.yaml <<EOL
mirrors:
  docker.io:
    endpoint:
      - \"https://$HOST_IP:27443\"
configs:
  \"$HOST_IP:27443\":
    tls:
      cert_file: /home/ngd/.certs/registry.crt
      key_file:  /home/ngd/.certs/registry.key
      ca_file:   /home/ngd/.certs/registry.crt
EOL
"

  sudo service k3s restart
}

deploy_certificate_to_buildx_builder()
{
  echo "Deploying to buildx builder"

  if [ "$(docker ps | grep buildx_buildkit_mybuilder0)" = "" ]
  then
    echo "Buildx container not found, skipping buildx builder deploy"
    return
  fi

  # Get the certificates inside the container and check if our certificate is inside it
  docker cp buildx_buildkit_mybuilder0:/etc/ssl/certs/ca-certificates.crt .
  HAS_CRT=`python3 -c "x=open('/home/$USER/.certs/registry.crt').read(); y=open('./ca-certificates.crt').read(); print(x in y)"`

  if [ "$HAS_CRT" = "False" ]
  then

    # Update the certificates to include our certificate
    cat /home/$USER/.certs/registry.crt >> ./ca-certificates.crt
    echo "" >> ./ca-certificates.crt

    # Deploy the new certificates
    docker exec -it buildx_buildkit_mybuilder0 mv /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt.bak
    docker cp ca-certificates.crt buildx_buildkit_mybuilder0:/etc/ssl/certs/ca-certificates.crt
    rm ca-certificates.crt

    # Restart the container to make every program read the certificates file again
    docker restart buildx_buildkit_mybuilder0
  fi
}

deploy_certificate_to_all_nodes()
{
  echo "Deploying to all drivers"

  for NODE in $NODES
  do
    echo "Deploying certificate to node $NODE"
    deploy_certificate_to_node $NODE &
  done

  wait
}

sudo chmod 644 ~/.certs/registry.key

deploy_certificate_to_host
deploy_certificate_to_buildx_builder
deploy_certificate_to_all_nodes

sudo chmod 600 ~/.certs/registry.key

echo "Done!"

