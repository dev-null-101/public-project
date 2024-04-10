README
======

Requirements:
-----------------------------------
1. Create Public and Private load balancers
2. Auto-Scaling
3. Create an Ingress using Nginx Ingress
4. Secure the Ingress with TLS & Cert-manager
5. Test Workload Identity


Workflows:
----------
* Virtual Network + subnet
* Managed Identity for the AKS cluster + bind it to role Network Contributor
* Default node group + spot nodes
* Enable OIDC and Workload Identity

Commands:
---------
* az aks get-credentials --resource-group <rg> --name <aksname>
* kubectl get nodes
* kubectl get svc