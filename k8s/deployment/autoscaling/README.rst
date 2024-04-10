NOTES:
------
| kubectl get nodes
| kubectl apply -f k8s/deployment/autoscaling
| kubectl get pods
| kubectl describe pods <pods-name>
| kubectl delete -f k8s/deployment/autoscaling
| *Notice that some pods will be in pending till the autoscaling is done.