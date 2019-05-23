#!/bin/sh                

#---------- Install Client Tools ----------

sudo apt-get install -y nginx
cat > kubernetes.default.svc.cluster.local <<EOF
server {
  listen      80;
    server_name kubernetes.default.svc.cluster.local;

      location /healthz {
           proxy_pass                    https://127.0.0.1:6443/healthz;
	        proxy_ssl_trusted_certificate /var/lib/kubernetes/ca.pem;
		  }
	  }
EOF
	  {
		    sudo mv kubernetes.default.svc.cluster.local \
			        /etc/nginx/sites-available/kubernetes.default.svc.cluster.local

		      sudo ln -s /etc/nginx/sites-available/kubernetes.default.svc.cluster.local /etc/nginx/sites-enabled/
	      }
	      sudo systemctl restart nginx
	      sudo systemctl enable nginx

kubectl get componentstatuses --kubeconfig admin.kubeconfig

curl -H "Host: kubernetes.default.svc.cluster.local" -i http://127.0.0.1/healthz

cat <<EOF | kubectl apply --kubeconfig admin.kubeconfig -f -

apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
    kubernetes.io/bootstrapping: rbac-defaults
  name: system:kube-apiserver-to-kubelet
 rules:
  - apiGroups:
      - ""
    resources:
      - nodes/proxy
      - nodes/stats
      - nodes/log
      - nodes/spec
      - nodes/metrics
    verbs:
      - "*"
EOF

cat <<EOF | kubectl apply --kubeconfig admin.kubeconfig -f -

apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: system:kube-apiserver
  namespace: ""
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: system:kube-apiserver-to-kubelet
subjects:
  - apiGroup: rbac.authorization.k8s.io
    kind: User
    name: kubernetes
EOF
