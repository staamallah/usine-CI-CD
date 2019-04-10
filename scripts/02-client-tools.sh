#!/bin/sh                

#---------- Install Client Tools ----------

echo "..... Install CFSSL ....."

wget -q --show-progress --https-only --timestamping \
	  https://pkg.cfssl.org/R1.2/cfssl_linux-amd64 \
	    https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64

chmod +x cfssl_linux-amd64 cfssljson_linux-amd64

sudo mv cfssl_linux-amd64 /usr/local/bin/cfssl

sudo mv cfssljson_linux-amd64 /usr/local/bin/cfssljson

echo "..... Verify cfssl version ....."

cfssl version


echo "..... Install kubectl ....." 

wget https://storage.googleapis.com/kubernetes-release/release/v1.12.0/bin/linux/amd64/kubectl

chmod +x kubectl

sudo mv kubectl /usr/local/bin/

echo "..... Verify kubectl version ....."

kubectl version --client
