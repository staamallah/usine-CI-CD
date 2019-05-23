#!/bin/sh                

#---------- bootstrapping the Kubelet ----------

echo "..... Create kubelet-config.yaml ....."



cat <<EOF | sudo tee /var/lib/kubelet/kubelet-config.yaml
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
authentication:
  anonymous:
    enabled: false
  webhook:
    enabled: true
  x509:
    clientCAFile: "/var/lib/kubernetes/ca.pem"
authorization:
  mode: Webhook
clusterDomain: "cluster.local"
clusterDNS:
  - "10.32.0.10"
podCIDR: "${POD_CIDR}"
resolvConf: "/run/systemd/resolve/resolv.conf"
runtimeRequestTimeout: "15m"
tlsCertFile: "/var/lib/kubelet/${HOSTNAME}.pem"
tlsPrivateKeyFile: "/var/lib/kubelet/${HOSTNAME}-key.pem"
EOF


echo "..... Create the  kubelet.service ....."


cat <<EOF | sudo tee /etc/systemd/system/kubelet.service

[Unit]
Description=Kubernetes Kubelet
Documentation=https://github.com/kubernetes/kubernetes
After=containerd.service
Requires=containerd.service

[Service]

ExecStart=/usr/local/bin/kubelet \\
	--config=/var/lib/kubelet/kubelet-config.yaml \\
	--container-runtime=remote \\
	--container-runtime-endpoint=unix:///var/run/containerd/containerd.sock \\
        --image-pull-progress-deadline=2m \\
	--kubeconfig=/var/lib/kubelet/kubeconfig \\
	--network-plugin=cni \\
	--register-node=true \\
	--v=2
	Restart=on-failure
	RestartSec=5

[Install]
	
	WantedBy=multi-user.target
EOF



