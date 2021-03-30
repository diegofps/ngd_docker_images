#!/bin/sh

POLICY=$1

update_policy()
{
  FILEPATH=$1
  cat $FILEPATH | sed "s/imagePullPolicy: \w\+/imagePullPolicy: $POLICY/" > ./tmp
  mv ./tmp $FILEPATH
}

update_policy "primary.yaml"
update_policy "client.yaml"
update_policy "secondary_host.yaml"
update_policy "secondary_csd.yaml"

