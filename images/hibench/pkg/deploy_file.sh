#!/bin/sh


if [ ! "$#" = "3" ]; then
  echo "SINTAX: $0 <POD_PATTERN> <LOCAL_FILE> <REMOTE_FILE>"
  exit 1
fi

POD_PATTERN=$1
SRC_FILE=$2
DST_FILE=$3

CONTAINERS=$(sudo kubectl get pods -o wide \
    | grep "$POD_PATTERN" \
    | awk '{ print $1 }')

deploy()
{
  CONT=$1

  echo "Deploying to $CONT"
  sudo kubectl cp $SRC_FILE $CONT:$DST_FILE
  echo "Deploy to $CONT completed"
}

for c in $CONTAINERS
do
  deploy $c &
done

wait

echo "Done!"

