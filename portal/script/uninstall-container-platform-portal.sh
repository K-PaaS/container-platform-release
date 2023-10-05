#!/bin/bash

source container-platform-portal-vars.sh

read -p "Are you sure you want to delete the container platform portal? <y/n> " prompt
if [[ $prompt == "y" || $prompt == "Y" || $prompt == "yes" || $prompt == "Yes" ]]
then
  # Uninstall Helm
  sudo helm uninstall container-platform-harbor --namespace $REPOSITORY_NAMESPACE
  sudo helm uninstall container-platform-mariadb --namespace $DATABASE_NAMESPACE
  sudo helm uninstall container-platform-keycloak --namespace $KEYCLOAK_NAMESPACE
  sudo helm uninstall container-platform-nfs-storageclass --namespace $NFS_NAMESPACE

  sudo helm uninstall container-platform-api --namespace $CONTAINER_PLATFORM_PORTAL_NAMESPACE
  sudo helm uninstall container-platform-common-api --namespace $CONTAINER_PLATFORM_PORTAL_NAMESPACE
  sudo helm uninstall container-platform-webadmin --namespace $CONTAINER_PLATFORM_PORTAL_NAMESPACE
  sudo helm uninstall container-platform-webuser --namespace $CONTAINER_PLATFORM_PORTAL_NAMESPACE
  if [ "$CONTAINER_PLATFORM_PORTAL_PROVIDER_TYPE" == "container-platform-portal-service" ]; then
    sudo helm uninstall container-platform-admin-service-broker --namespace $CONTAINER_PLATFORM_PORTAL_NAMESPACE
    sudo helm uninstall container-platform-user-service-broker --namespace $CONTAINER_PLATFORM_PORTAL_NAMESPACE
  fi

  # Delete Namespace
  kubectl delete ns $REPOSITORY_NAMESPACE
  kubectl delete ns $DATABASE_NAMESPACE
  kubectl delete ns $KEYCLOAK_NAMESPACE
  kubectl delete ns $NFS_NAMESPACE
  kubectl delete ns $CONTAINER_PLATFORM_PORTAL_NAMESPACE

  # Delete Helm repo and cm-push plugin
  sudo helm repo remove $REPOSITORY_PROJECT_NAME
  sudo helm plugin remove cm-push

  # Delete values dir
  rm -r ../values
  rm -r ../keycloak

  echo
  echo "-----------------------------------------------------------------------------"
  echo "* kubectl get ns"
  echo "-----------------------------------------------------------------------------"
  kubectl get ns
  echo
  echo "-----------------------------------------------------------------------------"
  echo "* sudo helm list --all-namespaces"
  echo "-----------------------------------------------------------------------------"
  sudo helm list --all-namespaces
  echo
  echo "-----------------------------------------------------------------------------"
  echo "* sudo helm repo list"
  echo "-----------------------------------------------------------------------------"
  sudo helm repo list
  echo
  echo
  echo
else
  exit 0
fi

