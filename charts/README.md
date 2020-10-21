# Before you begin

## Copy/Create your cluster client and server certificates

```bash
mkdir -p ~/.ngd/keys && sudo cp \
    /var/lib/rancher/k3s/server/tls/client-admin.crt \
    /var/lib/rancher/k3s/server/tls/client-admin.key \
    /var/lib/rancher/k3s/server/tls/server-ca.crt \
    ~/.ngd/keys && sudo chown $USER:$USER ~/.ngd/keys/*
```

# Charts

## telemetry

Make sure you are running telemetry, this is required by openalpr, facedetection and tesseract

```bash
helm install telemetry demo_ws_telemetry
```

## openalpr

To install it

```bash
helm install openalpr demo_ws_openalpr \
    --set loadbalancer.apiserverkeys=${HOME}/.ngd/keys \
    --set loadbalancer.apiserver=https://10.20.31.92:6443
```

## facedetection

```bash
helm install facedetection demo_ws_facedetection \
    --set loadbalancer.apiserverkeys=${HOME}/.ngd/keys \
    --set loadbalancer.apiserver=https://10.20.31.92:6443
```

## tesseract

```bash
helm install tesseract demo_ws_tesseract \
    --set loadbalancer.apiserverkeys=${HOME}/.ngd/keys \
    --set loadbalancer.apiserver=https://10.20.31.92:6443
```

## monitor1

```bash
# Make sure all your nodes have the target folder, which will be monitored
parallel-ssh -h ~/nodes -i -t 0 'sudo mkdir -p /media/storage'

# Make sure your cron node has the output folder, where it will save the exported parquet files
ssh node4 'sudo mkdir -p /media/storage_cron && sudo chmod 777 /media/storage_cron'

# Start the monitor with basic configuration
helm install mad monitor1

# Start the monitor customizing some configurations
helm install mad monitor1 \
    --set monitor.hosttarget="/media/storage" \
    --set cron.schedule='*/10 * * * *' \
    --set cron.hosttarget="/media/storage_cron" \
    --set cron.buffersize=10000 \
    --set cron.node=node4
```
