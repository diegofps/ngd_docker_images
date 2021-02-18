# Deploy

```
sudo kubectl create -f 'primary.yaml'
sudo kubectl create -f 'primary_service.yaml'
sudo kubectl create -f 'secondary.yaml'

sudo kubectl create -f 'client.yaml'
```

# Undeploy

```
sudo kubectl delete -f 'primary.yaml'
sudo kubectl delete -f 'primary_service.yaml'
sudo kubectl delete -f 'secondary.yaml'

sudo kubectl delete -f 'client.yaml'
```

# Clear Data in all datanodes

```
parallel-ssh -h ~/nodes -i -t 0 'sudo rm -rf /media/storage/dfs_datanode'
```
