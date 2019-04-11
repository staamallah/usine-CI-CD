#!/bin/sh                

#---------- Kubernetes Configuration Files ----------

mkdir kubernetes-configuration-files

cd kubernetes-configuration-files 

echo "..... Generate kubelet Kubernetes Configuration File ....."

KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe terraform-kubernetes-the-hard-way \
	  --region $(gcloud config get-value compute/region) \
	    --format 'value(address)')


for instance in terraform-worker-0 terraform-worker-1 terraform-worker-2; do
	  kubectl config set-cluster terraform-kubernetes-the-hard-way \
		      --certificate-authority=../certificate-configuration-files/ca.pem \
		          --embed-certs=true \
			      --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
			          --kubeconfig=${instance}.kubeconfig

	    kubectl config set-credentials system:node:${instance} \
		        --client-certificate=../certificate-configuration-files/${instance}.pem \
			    --client-key=../certificate-configuration-files/${instance}-key.pem \
			        --embed-certs=true \
				    --kubeconfig=${instance}.kubeconfig

	      kubectl config set-context default \
		          --cluster=terraform-kubernetes-the-hard-way \
			      --user=system:node:${instance} \
			          --kubeconfig=${instance}.kubeconfig

	        kubectl config use-context default --kubeconfig=${instance}.kubeconfig
done


echo "..... Generate kube Proxy Kubernetes Configuration File ....."

	 kubectl config set-cluster terraform-kubernetes-the-hard-way \
	     --certificate-authority=../certificate-configuration-files/ca.pem \
	         --embed-certs=true \
		     --server=https://${KUBERNETES_PUBLIC_ADDRESS}:6443 \
		         --kubeconfig=kube-proxy.kubeconfig

  	 kubectl config set-credentials system:kube-proxy \
	       --client-certificate=../certificate-configuration-files/kube-proxy.pem \
	           --client-key=../certificate-configuration-files/kube-proxy-key.pem \
		       --embed-certs=true \
		           --kubeconfig=kube-proxy.kubeconfig

    	 kubectl config set-context default \
	         --cluster=terraform-kubernetes-the-hard-way \
		     --user=system:kube-proxy \
		         --kubeconfig=kube-proxy.kubeconfig

      	 kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig


echo "..... Generate kube Controller Manager Kubernetes Configuration File ....."


	kubectl config set-cluster terraform-kubernetes-the-hard-way \
	    --certificate-authority=../certificate-configuration-files/ca.pem \
	        --embed-certs=true \
		    --server=https://127.0.0.1:6443 \
		        --kubeconfig=kube-controller-manager.kubeconfig

 	kubectl config set-credentials system:kube-controller-manager \
	      --client-certificate=../certificate-configuration-files/kube-controller-manager.pem \
	          --client-key=../certificate-configuration-files/kube-controller-manager-key.pem \
		      --embed-certs=true \
		          --kubeconfig=kube-controller-manager.kubeconfig

   	kubectl config set-context default \
	        --cluster=terraform-kubernetes-the-hard-way \
		    --user=system:kube-controller-manager \
		        --kubeconfig=kube-controller-manager.kubeconfig

      	kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig


echo "..... Generate kube Scheduler Kubernetes Configuration File ....."
	

	kubectl config set-cluster terraform-kubernetes-the-hard-way \
	    --certificate-authority=../certificate-configuration-files/ca.pem \
	        --embed-certs=true \
		    --server=https://127.0.0.1:6443 \
		        --kubeconfig=kube-scheduler.kubeconfig

 	kubectl config set-credentials system:kube-scheduler \
	      --client-certificate=../certificate-configuration-files/kube-scheduler.pem \
	          --client-key=../certificate-configuration-files/kube-scheduler-key.pem \
		      --embed-certs=true \
		          --kubeconfig=kube-scheduler.kubeconfig

   	kubectl config set-context default \
	        --cluster=terraform-kubernetes-the-hard-way \
		    --user=system:kube-scheduler \
		        --kubeconfig=kube-scheduler.kubeconfig

     	kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig




echo "..... Generate Admin Kubernetes Configuration File ....."
 
	kubectl config set-cluster terraform-kubernetes-the-hard-way \
	      --certificate-authority=../certificate-configuration-files/ca.pem \
	          --embed-certs=true \
		      --server=https://127.0.0.1:6443 \
		          --kubeconfig=admin.kubeconfig

   	kubectl config set-credentials admin \
	        --client-certificate=../certificate-configuration-files/admin.pem \
		    --client-key=../certificate-configuration-files/admin-key.pem \
		        --embed-certs=true \
			    --kubeconfig=admin.kubeconfig

     	kubectl config set-context default \
	          --cluster=terraform-kubernetes-the-hard-way \
		      --user=admin \
		          --kubeconfig=admin.kubeconfig

        kubectl config use-context default --kubeconfig=admin.kubeconfig



