#!/bin/sh

if [ "$#" = "0" ]; then
  echo "SINTAX: $0 <POLICY=IfNotPresent|Always>"
  exit 1
fi

POLICY=$1

update_policy()
{
  FILEPATH=$1
  cat $FILEPATH | sed "s/imagePullPolicy: \w\+/imagePullPolicy: $POLICY/" > ./tmp
  mv ./tmp $FILEPATH
}

update_policy "hadoop_primary.yaml"
update_policy "hadoop_worker_csd.yaml"
update_policy "hadoop_worker_host.yaml"

update_policy "spark_primary.yaml"
update_policy "spark_worker_csd.yaml"
update_policy "spark_worker_host.yaml"

echo "Done!"
