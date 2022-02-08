#!/bin/bash

source container-platform-pipeline-vars.sh

kubectl delete --all deployments --namespace=$NAMESPACE
kubectl delete --all pods --grace-period=0 --force --namespace=$NAMESPACE
kubectl delete --all replicasets --namespace=$NAMESPACE
kubectl delete --all services --namespace=$NAMESPACE

rm -r ../values

if [[ "$PROVIDER_TYPE" == *standalone* ]]; then
  unset IMAGE_NAME[2]
fi

for IMAGE in ${IMAGE_NAME[@]}
do
  if [[ "$IMAGE" == *pipeline* ]]; then
    sudo helm uninstall $IMAGE --namespace $NAMESPACE
  fi
done


sudo helm repo remove $REPOSITORY_PROJECT_NAME
kubectl delete ns $NAMESPACE
helm plugin list
helm repo list
helm list

kubectl get ns

