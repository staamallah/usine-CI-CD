#!/bin/sh                

#---------- Provisioning a CA and Generating TLS Certificates ----------

mkdir certificate-configuration-files

cd certificate-configuration-files 

echo "..... Generate Certificate Authority ....."

cat > ca-config.json <<EOF
{
       	"signing": {
		"default": {
			"expiry": "8760h"
			},
	"profiles": {
	"kubernetes": {
	"usages": ["signing", "key encipherment", "server auth", "client auth"],
	"expiry": "8760h"
			}
		 }
		}
}
EOF

cat > ca-csr.json <<EOF
{
	"CN": "Kubernetes",
	"key": {
	"algo": "rsa",
	"size": 2048
		},
		"names": [
		{
		"C": "US",
		"L": "Portland",
		"O": "Kubernetes",
		"OU": "CA",
		"ST": "Oregon"
		}
			]
}
EOF

cfssl gencert -initca ca-csr.json | cfssljson -bare ca


echo "..... Generate Admin Client Certificate ....."


cat > admin-csr.json <<EOF
{
	"CN": "admin",
	"key": {
	"algo": "rsa",
	"size": 2048
		},
		"names": [
		{
			"C": "US",
			"L": "Portland",
			"O": "system:masters",
			"OU": "Kubernetes The Hard Way",
			"ST": "Oregon"
		}
			 ]
	}
EOF

	cfssl gencert \
		-ca=ca.pem \
		-ca-key=ca-key.pem \
		-config=ca-config.json \
		-profile=kubernetes \
	admin-csr.json | cfssljson -bare admin



echo"..... Generate Kubelet Client Certificates ....." 


for instance in terraform-worker-0 terraform-worker-1 terraform-worker-2; do

cat > ${instance}-csr.json <<EOF
{
	"CN": "system:node:${instance}",
	"key": {
	"algo": "rsa",
	"size": 2048
		},
		"names": [
		{
			"C": "US",
			"L": "Portland",
			"O": "system:nodes",
			"OU": "Kubernetes The Hard Way",
			"ST": "Oregon"
		}
			]
}
EOF

EXTERNAL_IP=$(gcloud compute instances describe ${instance} \
	  --format 'value(networkInterfaces[0].accessConfigs[0].natIP)')

INTERNAL_IP=$(gcloud compute instances describe ${instance} \
	  --format 'value(networkInterfaces[0].networkIP)')

cfssl gencert \
	  -ca=ca.pem \
	    -ca-key=ca-key.pem \
	      -config=ca-config.json \
	        -hostname=${instance},${EXTERNAL_IP},${INTERNAL_IP} \
		  -profile=kubernetes \
		    ${instance}-csr.json | cfssljson -bare ${instance}
done


echo"..... Generate Controller Manager Client Certificate ....."


cat > kube-controller-manager-csr.json <<EOF
{
	"CN": "system:kube-controller-manager",
	"key": {
	"algo": "rsa",
	"size": 2048
		},
		"names": [
		{
			"C": "US",
			"L": "Portland",
			"O": "system:kube-controller-manager",
			"OU": "Kubernetes The Hard Way",
			"ST": "Oregon"
		}
			]
}
EOF

	cfssl gencert \
		-ca=ca.pem \
		-ca-key=ca-key.pem \
		-config=ca-config.json \
		-profile=kubernetes \
	kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager


echo "..... generate Kube Proxy Client Certificate ....."

cat > kube-proxy-csr.json <<EOF
{
	"CN": "system:kube-proxy",
	"key": {
	"algo": "rsa",
	"size": 2048
		},
		"names": [
		 {
			"C": "US",
			"L": "Portland",
			"O": "system:node-proxier",
			"OU": "Kubernetes The Hard Way",
			"ST": "Oregon"
		}
			]
}
EOF

	cfssl gencert \
		-ca=ca.pem \
		-ca-key=ca-key.pem \
		-config=ca-config.json \
		-profile=kubernetes \
	kube-proxy-csr.json | cfssljson -bare kube-proxy



echo "..... Generate Scheduler Client Certificate ....."


cat > kube-scheduler-csr.json <<EOF
{
	"CN": "system:kube-scheduler",
	"key": {
	"algo": "rsa",
	"size": 2048
		},
		"names": [
		{
			"C": "US",
			"L": "Portland",
			"O": "system:kube-scheduler",
			"OU": "Kubernetes The Hard Way",
			"ST": "Oregon"
		}
	]
}
EOF

	cfssl gencert \
		-ca=ca.pem \
		-ca-key=ca-key.pem \
		-config=ca-config.json \
		-profile=kubernetes \
	kube-scheduler-csr.json | cfssljson -bare kube-scheduler


echo "..... Generate Kubernetes API Server Certificate ....."


KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe terraform-kubernetes-the-hard-way \
	  --region $(gcloud config get-value compute/region) \
	    --format 'value(address)')

cat > kubernetes-csr.json <<EOF
{
	"CN": "kubernetes",
	"key": {
	"algo": "rsa",
	"size": 2048
		},
		"names": [
		{
			"C": "US",
			"L": "Portland",
			"O": "Kubernetes",
			"OU": "Kubernetes The Hard Way",
			"ST": "Oregon"
		 }
	]
}
EOF

	cfssl gencert \
		-ca=ca.pem \
		-ca-key=ca-key.pem \
		-config=ca-config.json \
		-hostname=10.50.0.1,10.250.0.10,10.250.0.11,10.250.0.12,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,kubernetes.default \
		-profile=kubernetes \
	kubernetes-csr.json | cfssljson -bare kubernetes


echo "..... Generate Service Account Key Pair ....."


cat > service-account-csr.json <<EOF
{
	"CN": "service-accounts",
	"key": {
	"algo": "rsa",
	"size": 2048
		},
		"names": [
		{
			"C": "US",
			"L": "Portland",
			"O": "Kubernetes",
			"OU": "Kubernetes The Hard Way",
			"ST": "Oregon"
		}
	]
}
EOF

	cfssl gencert \
		-ca=ca.pem \
		-ca-key=ca-key.pem \
		-config=ca-config.json \
		-profile=kubernetes \
	 service-account-csr.json | cfssljson -bare service-account
