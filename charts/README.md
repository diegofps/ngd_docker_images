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

## telemetry

```bash
helm install telemetry demo_ws_telemetry
```
