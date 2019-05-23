#!/bin/sh                

#---------- Verification ----------
{
	  KUBERNETES_PUBLIC_ADDRESS=$(gcloud compute addresses describe terraform-kubernetes-the-hard-way \
		      --region $(gcloud config get-value compute/region) \
		          --format 'value(address)')

	    gcloud compute http-health-checks create terraform-kubernetes \
		        --description "Kubernetes Health Check" \
			    --host "kubernetes.default.svc.cluster.local" \
			        --request-path "/healthz"

	      gcloud compute firewall-rules create terraform-kubernetes-the-hard-way-allow-health-check \
		          --network terraform-kubernetes-the-hard-way \
			      --source-ranges 209.85.152.0/22,209.85.204.0/22,35.191.0.0/16 \
			          --allow tcp

	        gcloud compute target-pools create terraform-kubernetes-target-pool \
			    --http-health-check terraform-kubernetes

		  gcloud compute target-pools add-instances terraform-kubernetes-target-pool \
			     --instances terraform-controller-0,terraform-controller-1,terraform-controller-2

		    gcloud compute forwarding-rules create terraform-kubernetes-forwarding-rule \
			        --address ${KUBERNETES_PUBLIC_ADDRESS} \
				    --ports 6443 \
				        --region $(gcloud config get-value compute/region) \
					    --target-pool terraform-kubernetes-target-pool
	    }

	    curl --cacert ca.pem https://${KUBERNETES_PUBLIC_ADDRESS}:6443/version
