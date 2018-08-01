oc delete -f redis-slave-service.yaml
oc delete -f frontend-deployment.yaml
oc delete -f frontend-service.yaml
oc delete -f redis-slave-deployment.yaml
oc delete -f redis-slave-service.yaml
oc delete -f redis-master-deployment.yaml
oc delete -f redis-master-service.yaml
