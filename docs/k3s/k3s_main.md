# Welcome

This page describes some utilities on how to configure kubernetes on a Newport cluster using k3s.

# Dependencies

1. [Configure the bin folder](../index.md)

# Install k3s

```bash
# This will install the configure the Host as a server node and all Newport devices as agents. It will also apply some configuration patches for bugfixes
k3s_install.sh

# Check if all nodes are ready with the following command
sudo kubectl get nodes - o wide
```

# Uninstall k3s

```bash
# This will call k3s-uninstall.sh in the Host and k3s-agent-uninstall.sh on every Newport
k3s_uninstall.sh
```

