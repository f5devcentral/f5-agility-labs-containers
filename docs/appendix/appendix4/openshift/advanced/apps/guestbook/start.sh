oc create -f redis-master-deployment.yaml
oc create -f redis-master-service.yaml
oc create -f redis-slave-deployment.yaml
oc create -f redis-slave-service.yaml
oc create -f frontend-deployment.yaml
oc create -f frontend-service.yaml
