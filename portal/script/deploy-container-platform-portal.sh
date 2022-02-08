#!/bin/bash

source container-platform-portal-vars.sh

# Copy values directory
cp -r ../values_orig ../values
cp -r ../keycloak_orig ../keycloak

# Replace Vars Values
find ../keycloak -name "Dockerfile" -exec sed -i "s/{CONTAINER_PLATFORM_PORTAL_PROVIDER_TYPE}/$CONTAINER_PLATFORM_PORTAL_PROVIDER_TYPE/g" {} \;
find ../keycloak -name "*.json" -exec sed -i "s/{K8S_MASTER_NODE_IP}/$K8S_MASTER_NODE_IP/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{K8S_MASTER_NODE_IP}/$K8S_MASTER_NODE_IP/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{K8S_API_SERVER_PORT}/$K8S_API_SERVER_PORT/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{K8S_AUTH_BEARER_TOKEN}/$K8S_AUTH_BEARER_TOKEN/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{SERVICE_TYPE}/$SERVICE_TYPE/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{SERVICE_PROTOCOL}/$SERVICE_PROTOCOL/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{REPOSITORY_NAMESPACE}/$REPOSITORY_NAMESPACE/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{REPOSITORY_URL}/$REPOSITORY_URL/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{REPOSITORY_PASSWORD}/$REPOSITORY_PASSWORD/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{REPOSITORY_PROJECT_NAME}/$REPOSITORY_PROJECT_NAME/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{IMAGE_TAGS}/$IMAGE_TAGS/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{IMAGE_PULL_POLICY}/$IMAGE_PULL_POLICY/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{IMAGE_PULL_SECRET}/$IMAGE_PULL_SECRET/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{DATABASE_NAMESPACE}/$DATABASE_NAMESPACE/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{DATABASE_URL}/$DATABASE_URL/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{DATABASE_USER_ID}/$DATABASE_USER_ID/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{DATABASE_USER_PASSWORD}/$DATABASE_USER_PASSWORD/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{KEYCLOAK_NAMESPACE}/$KEYCLOAK_NAMESPACE/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s@{KEYCLOAK_URL}@$KEYCLOAK_URL@g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{KEYCLOAK_DB_VENDOR}/$KEYCLOAK_DB_VENDOR/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{KEYCLOAK_DB_SCHEMA}/$KEYCLOAK_DB_SCHEMA/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{KEYCLOAK_ADMIN_USERNAME}/$KEYCLOAK_ADMIN_USERNAME/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{KEYCLOAK_ADMIN_PASSWORD}/$KEYCLOAK_ADMIN_PASSWORD/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{KEYCLOAK_SESSIONS_COUNT}/$KEYCLOAK_SESSIONS_COUNT/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{KEYCLOAK_LOG_LEVEL}/$KEYCLOAK_LOG_LEVEL/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{KEYCLOAK_CP_REALM}/$KEYCLOAK_CP_REALM/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{KEYCLOAK_CP_CLIENT_ID}/$KEYCLOAK_CP_CLIENT_ID/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{KEYCLOAK_CP_CLIENT_SECRET}/$KEYCLOAK_CP_CLIENT_SECRET/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{CONTAINER_PLATFORM_PORTAL_NAMESPACE}/$CONTAINER_PLATFORM_PORTAL_NAMESPACE/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{CONTAINER_PLATFORM_PORTAL_PROVIDER_TYPE}/$CONTAINER_PLATFORM_PORTAL_PROVIDER_TYPE/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{NFS_NAMESPACE}/$NFS_NAMESPACE/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{NFS_SERVER_IP}/$NFS_SERVER_IP/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{NFS_STORAGECLASS_NAME}/$NFS_STORAGECLASS_NAME/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{CONTAINER_PLATFORM_PIPELINE_NAMESPACE}/$CONTAINER_PLATFORM_PIPELINE_NAMESPACE/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{CONTAINER_PLATFORM_SOURCE_CONTROL_NAMESPACE}/$CONTAINER_PLATFORM_SOURCE_CONTROL_NAMESPACE/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{CONTAINER_PLATFORM_DEFAULT_INGRESS_NAMESPACE}/$CONTAINER_PLATFORM_DEFAULT_INGRESS_NAMESPACE/g" {} \;

# 1. Deploy the NFS StorageClass
kubectl create namespace $NFS_NAMESPACE
sudo helm install -f ../values/paas-ta-container-platform-nfs-storageclass-values.yaml paas-ta-container-platform-nfs-storageclass ../charts/paas-ta-container-platform-nfs-storageclass-chart.tgz --namespace $NFS_NAMESPACE

# 2. Deploy the Harbor
kubectl create namespace $REPOSITORY_NAMESPACE
sudo helm install -f ../values/paas-ta-container-platform-harbor-values.yaml paas-ta-container-platform-harbor ../charts/paas-ta-container-platform-harbor-chart.tgz --namespace $REPOSITORY_NAMESPACE

REPOSITORY_HTTP_CODE=$(curl -L -k -s -o /dev/null -w "%{http_code}\n" $REPOSITORY_URL/api/v2.0/projects)
while :
do
  if [ $REPOSITORY_HTTP_CODE -eq 200 ]; then
    break
  fi

  echo "[$REPOSITORY_HTTP_CODE] Please wait for several minutes for Harbor deployment to complete..."
  sleep 10
  REPOSITORY_HTTP_CODE=$(curl -L -k -s -o /dev/null -w "%{http_code}\n" $REPOSITORY_URL/api/v2.0/projects)
done

# 3. Create a project in Harbor
sudo podman login http://$REPOSITORY_URL --username $REPOSITORY_USERNAME --password $REPOSITORY_PASSWORD
curl -u $REPOSITORY_USERNAME:$REPOSITORY_PASSWORD -k http://$REPOSITORY_URL/api/v2.0/projects -XPOST --data-binary "{\"project_name\": \"$REPOSITORY_PROJECT_NAME\", \"public\": false}" -H "Content-Type: application/json" -i
sudo helm repo add $REPOSITORY_PROJECT_NAME --username $REPOSITORY_USERNAME --password $REPOSITORY_PASSWORD http://$REPOSITORY_URL/chartrepo/$REPOSITORY_PROJECT_NAME
sudo helm plugin install https://github.com/chartmuseum/helm-push.git


# 4. Push the Keycloak Image in Harbor
cd ../keycloak
sudo podman build --tag $REPOSITORY_URL/$REPOSITORY_PROJECT_NAME/paas-ta-container-platform-keycloak:latest .
sudo podman push $REPOSITORY_URL/$REPOSITORY_PROJECT_NAME/paas-ta-container-platform-keycloak
cd ../script


# 5. Push the Container Platform Portal Image in Harbor
sudo podman load -i ../images/paas-ta-container-platform-api-image.tar.gz
sudo podman load -i ../images/paas-ta-container-platform-common-api-image.tar.gz
sudo podman load -i ../images/paas-ta-container-platform-webadmin-image.tar.gz
sudo podman load -i ../images/paas-ta-container-platform-webuser-image.tar.gz
if [ "$CONTAINER_PLATFORM_PORTAL_PROVIDER_TYPE" == "paas-ta-container-platform-portal-service" ]; then
   sudo podman load -i ../images/paas-ta-container-platform-admin-service-broker-image.tar.gz
   sudo podman load -i ../images/paas-ta-container-platform-user-service-broker-image.tar.gz
fi

sudo podman tag localhost:5000/container-platform/paas-ta-container-platform-api $REPOSITORY_URL/$REPOSITORY_PROJECT_NAME/paas-ta-container-platform-api
sudo podman tag localhost:5000/container-platform/paas-ta-container-platform-common-api $REPOSITORY_URL/$REPOSITORY_PROJECT_NAME/paas-ta-container-platform-common-api
sudo podman tag localhost:5000/container-platform/paas-ta-container-platform-webadmin $REPOSITORY_URL/$REPOSITORY_PROJECT_NAME/paas-ta-container-platform-webadmin
sudo podman tag localhost:5000/container-platform/paas-ta-container-platform-webuser $REPOSITORY_URL/$REPOSITORY_PROJECT_NAME/paas-ta-container-platform-webuser
if [ "$CONTAINER_PLATFORM_PORTAL_PROVIDER_TYPE" == "paas-ta-container-platform-portal-service" ]; then
   sudo podman tag localhost:5000/container-platform/paas-ta-container-platform-admin-service-broker $REPOSITORY_URL/$REPOSITORY_PROJECT_NAME/paas-ta-container-platform-admin-service-broker
   sudo podman tag localhost:5000/container-platform/paas-ta-container-platform-user-service-broker $REPOSITORY_URL/$REPOSITORY_PROJECT_NAME/paas-ta-container-platform-user-service-broker
fi

sudo podman push $REPOSITORY_URL/$REPOSITORY_PROJECT_NAME/paas-ta-container-platform-api
sudo podman push $REPOSITORY_URL/$REPOSITORY_PROJECT_NAME/paas-ta-container-platform-common-api
sudo podman push $REPOSITORY_URL/$REPOSITORY_PROJECT_NAME/paas-ta-container-platform-webadmin
sudo podman push $REPOSITORY_URL/$REPOSITORY_PROJECT_NAME/paas-ta-container-platform-webuser
if [ "$CONTAINER_PLATFORM_PORTAL_PROVIDER_TYPE" == "paas-ta-container-platform-portal-service" ]; then
   sudo podman push $REPOSITORY_URL/$REPOSITORY_PROJECT_NAME/paas-ta-container-platform-admin-service-broker
   sudo podman push $REPOSITORY_URL/$REPOSITORY_PROJECT_NAME/paas-ta-container-platform-user-service-broker
fi


# 6. Push the Helm Chart in Harbor
sudo helm cm-push --username $REPOSITORY_USERNAME --password $REPOSITORY_PASSWORD ../charts/paas-ta-container-platform-nfs-storageclass-chart.tgz $REPOSITORY_PROJECT_NAME
sudo helm cm-push --username $REPOSITORY_USERNAME --password $REPOSITORY_PASSWORD ../charts/paas-ta-container-platform-harbor-chart.tgz $REPOSITORY_PROJECT_NAME
sudo helm cm-push --username $REPOSITORY_USERNAME --password $REPOSITORY_PASSWORD ../charts/paas-ta-container-platform-mariadb-chart.tgz $REPOSITORY_PROJECT_NAME
sudo helm cm-push --username $REPOSITORY_USERNAME --password $REPOSITORY_PASSWORD ../charts/paas-ta-container-platform-keycloak-chart.tgz $REPOSITORY_PROJECT_NAME
sudo helm cm-push --username $REPOSITORY_USERNAME --password $REPOSITORY_PASSWORD ../charts/paas-ta-container-platform-api-chart.tgz $REPOSITORY_PROJECT_NAME
sudo helm cm-push --username $REPOSITORY_USERNAME --password $REPOSITORY_PASSWORD ../charts/paas-ta-container-platform-common-api-chart.tgz $REPOSITORY_PROJECT_NAME
sudo helm cm-push --username $REPOSITORY_USERNAME --password $REPOSITORY_PASSWORD ../charts/paas-ta-container-platform-webadmin-chart.tgz $REPOSITORY_PROJECT_NAME
sudo helm cm-push --username $REPOSITORY_USERNAME --password $REPOSITORY_PASSWORD ../charts/paas-ta-container-platform-webuser-chart.tgz $REPOSITORY_PROJECT_NAME
if [ "$CONTAINER_PLATFORM_PORTAL_PROVIDER_TYPE" == "paas-ta-container-platform-portal-service" ]; then
  sudo helm cm-push --username $REPOSITORY_USERNAME --password $REPOSITORY_PASSWORD ../charts/paas-ta-container-platform-admin-service-broker-chart.tgz $REPOSITORY_PROJECT_NAME
  sudo helm cm-push --username $REPOSITORY_USERNAME --password $REPOSITORY_PASSWORD ../charts/paas-ta-container-platform-user-service-broker-chart.tgz $REPOSITORY_PROJECT_NAME
fi
sudo helm repo update


# NFS & Harbor namespace create secret
kubectl create secret docker-registry $IMAGE_PULL_SECRET --docker-server=http://$REPOSITORY_URL --docker-username=$REPOSITORY_USERNAME --docker-password=$REPOSITORY_PASSWORD -n $NFS_NAMESPACE
kubectl create secret docker-registry $IMAGE_PULL_SECRET --docker-server=http://$REPOSITORY_URL --docker-username=$REPOSITORY_USERNAME --docker-password=$REPOSITORY_PASSWORD -n $REPOSITORY_NAMESPACE

# 7. Deploy the MariaDB
kubectl create namespace $DATABASE_NAMESPACE
kubectl create secret docker-registry $IMAGE_PULL_SECRET --docker-server=http://$REPOSITORY_URL --docker-username=$REPOSITORY_USERNAME --docker-password=$REPOSITORY_PASSWORD -n $DATABASE_NAMESPACE
kubectl apply -f ../values/paas-ta-container-platform-mariadb-configmap.yaml -n $DATABASE_NAMESPACE
sudo helm install -f ../values/paas-ta-container-platform-mariadb-values.yaml paas-ta-container-platform-mariadb $REPOSITORY_PROJECT_NAME/mariadb --namespace $DATABASE_NAMESPACE


# 8. Deploy the Keycloak
kubectl create namespace $KEYCLOAK_NAMESPACE
kubectl create secret docker-registry $IMAGE_PULL_SECRET --docker-server=http://$REPOSITORY_URL --docker-username=$REPOSITORY_USERNAME --docker-password=$REPOSITORY_PASSWORD -n $KEYCLOAK_NAMESPACE
sudo helm install -f ../values/paas-ta-container-platform-keycloak-values.yaml paas-ta-container-platform-keycloak $REPOSITORY_PROJECT_NAME/paas-ta-container-platform-keycloak --namespace $KEYCLOAK_NAMESPACE



# 9. Deploy the Container Platform Portal
kubectl create namespace $CONTAINER_PLATFORM_PORTAL_NAMESPACE
kubectl create secret docker-registry $IMAGE_PULL_SECRET --docker-server=http://$REPOSITORY_URL --docker-username=$REPOSITORY_USERNAME --docker-password=$REPOSITORY_PASSWORD -n $CONTAINER_PLATFORM_PORTAL_NAMESPACE
sudo helm install -f ../values/paas-ta-container-platform-api-values.yaml paas-ta-container-platform-api $REPOSITORY_PROJECT_NAME/paas-ta-container-platform-api --namespace $CONTAINER_PLATFORM_PORTAL_NAMESPACE
sudo helm install -f ../values/paas-ta-container-platform-common-api-values.yaml paas-ta-container-platform-common-api $REPOSITORY_PROJECT_NAME/paas-ta-container-platform-common-api --namespace $CONTAINER_PLATFORM_PORTAL_NAMESPACE
sudo helm install -f ../values/paas-ta-container-platform-webadmin-values.yaml paas-ta-container-platform-webadmin $REPOSITORY_PROJECT_NAME/paas-ta-container-platform-webadmin --namespace $CONTAINER_PLATFORM_PORTAL_NAMESPACE
sudo helm install -f ../values/paas-ta-container-platform-webuser-values.yaml paas-ta-container-platform-webuser $REPOSITORY_PROJECT_NAME/paas-ta-container-platform-webuser --namespace $CONTAINER_PLATFORM_PORTAL_NAMESPACE

if [ "$CONTAINER_PLATFORM_PORTAL_PROVIDER_TYPE" == "paas-ta-container-platform-portal-service" ]; then
   sudo helm install -f ../values/paas-ta-container-platform-admin-service-broker-values.yaml paas-ta-container-platform-admin-service-broker $REPOSITORY_PROJECT_NAME/paas-ta-container-platform-admin-service-broker --namespace $CONTAINER_PLATFORM_PORTAL_NAMESPACE
   sudo helm install -f ../values/paas-ta-container-platform-user-service-broker-values.yaml paas-ta-container-platform-user-service-broker $REPOSITORY_PROJECT_NAME/paas-ta-container-platform-user-service-broker --namespace $CONTAINER_PLATFORM_PORTAL_NAMESPACE
fi
