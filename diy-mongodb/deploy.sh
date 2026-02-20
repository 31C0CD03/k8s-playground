kubectl delete -f mongodb-svc.yaml,mongodb-cfm.yaml,mongodb-sts.yaml 2>/dev/null
kubectl delete pvc -l app=mongodb

set -e
kubectl apply -f mongodb-svc.yaml,mongodb-cfm.yaml,mongodb-sts.yaml
kubectl rollout status statefulset/mongodb --timeout=600s
sleep 2
kubectl exec -it mongodb-0 -- mongosh /docker-entrypoint-initdb.d/init_rs.js
PRIMARY=$(kubectl exec mongodb-0 -- mongosh --eval "rs.isMaster().primary" | cut -d'.' -f1)
kubectl exec -it $PRIMARY -- mongosh /docker-entrypoint-initdb.d/init_user.js
