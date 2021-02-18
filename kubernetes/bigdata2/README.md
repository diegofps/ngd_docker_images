# Deploy

```
sudo kubectl create -f 'primary.yaml'
sudo kubectl create -f 'primary_service.yaml'
sudo kubectl create -f 'secondary.yaml'
```

# Undeploy

```
sudo kubectl delete -f 'primary.yaml'
sudo kubectl delete -f 'primary_service.yaml'
sudo kubectl delete -f 'secondary.yaml'
```