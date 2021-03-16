#!/bin/sh


################################################################################
# Extract
################################################################################

echo "Extracting HiBench..."
tar -xf HiBench.tar.gz
mv hibench /hibench

tar xf m2.tar.gz
mv .m2 /root/


################################################################################
# Build
################################################################################

echo "Building HiBench..."
cd /hibench && mvn -T 2C -Dspark=3.0 -Dscala=2.12 package


################################################################################
# Configure
################################################################################

echo "Configuring HiBench..."

cat /hibench/conf/hadoop.conf.template | sed 's:/PATH/TO/YOUR/HADOOP/ROOT:/hadoop:' | sed 's|hdfs://localhost:8020|hdfs://bigdata2-primary:9000|' > /hibench/conf/hadoop.conf
cat /hibench/conf/spark.conf.template | sed 's:/PATH/TO/YOUR/SPARK/HOME:/spark:' | sed 's|   yarn-client|   spark://bigdata2-primary:7077|' > /hibench/conf/spark.conf

exit 0
