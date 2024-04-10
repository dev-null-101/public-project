NOTES:
------
| For Azure
| kubectl apply -f k8s/deployment/pub-priv-loadbalancer
| Monitor: watch kubectl get svc
| Test: curl http://<public ip>/
| Cleanup: kubectl delete -f k8s/pub-priv-loadbalancer