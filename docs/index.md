# Welcome

These tutorials are built in the hope that they will help people install, configure and use these demos. They are meant to be run inside an NGD cluster (For instance: One Host machine with multiple NGD Newports).

# Before you begin: Add the bin folder to your path

```bash
# Enter the bin folder in this repository
cd bin

# This will add the current path to your ~/.bashrc. If the path is already present nothing will be added
./install_pwd.sh
```

# You may now pick a task and start following that path

* [K3s](k3s/k3s_main.md) - This shows how to install k3s, uninstall it and check if everything is running fine.
* [Hadoop and Spark](bigdata2/bigdata2_main.md) - Shows how to deploy a local cluster with hadoop and spark and how to run some diverse applications.
* [Private docker registry](docker/private_registry.md) - Configure a local private registry. This is helpful when you want to work on a private or testing project and you don't want to upload it to a public registry, like docker hub.
