#!/bin/bash

source container-platform-pipeline-vars.sh

# Copy values directory
cp -r ../values_orig ../values

# Replace Vars Values
find ../values -name "*.yaml" -exec sed -i "s/{K8S_MASTER_NODE_IP}/$K8S_MASTER_NODE_IP/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{NAMESPACE}/$NAMESPACE/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{IMAGE_TAGS}/$IMAGE_TAGS/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{IMAGE_PULL_POLICY}/$IMAGE_PULL_POLICY/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{IMAGE_PULL_SECRET}/$IMAGE_PULL_SECRET/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{SERVICE_TYPE}/$SERVICE_TYPE/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{SERVICE_PROTOCOL}/$SERVICE_PROTOCOL/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{PERSISTENT_STORAGE_CLASS_NAME}/$PERSISTENT_STORAGE_CLASS_NAME/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s@{KEYCLOAK_URL}@$KEYCLOAK_URL@g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{KEYCLOAK_ADMIN_ID}/$KEYCLOAK_ADMIN_ID/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{KEYCLOAK_ADMIN_PASSWORD}/$KEYCLOAK_ADMIN_PASSWORD/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{KEYCLOAK_CP_REALM}/$KEYCLOAK_CP_REALM/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{KEYCLOAK_IDENTITY_PROVIDER_ID}/$KEYCLOAK_IDENTITY_PROVIDER_ID/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{KEYCLOAK_CLUSTER_ADMIN_GROUP}/$KEYCLOAK_CLUSTER_ADMIN_GROUP/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{KEYCLOAK_CLUSTER_ADMIN_ROLE}/$KEYCLOAK_CLUSTER_ADMIN_ROLE/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{KEYCLOAK_CP_CLIENT_ID}/$KEYCLOAK_CP_CLIENT_ID/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{KEYCLOAK_CP_CLIENT_SECRET}/$KEYCLOAK_CP_CLIENT_SECRET/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{DATABASE_URL}/$DATABASE_URL/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{DATABASE_USER_ID}/$DATABASE_USER_ID/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{DATABASE_USER_PASSWORD}/$DATABASE_USER_PASSWORD/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s@{CF_API_URL}@$CF_API_URL@g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{REPOSITORY_URL}/$REPOSITORY_URL/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{REPOSITORY_PROJECT_NAME}/$REPOSITORY_PROJECT_NAME/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{REPOSITORY_USERNAME}/$REPOSITORY_USERNAME/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{REPOSITORY_PASSWORD}/$REPOSITORY_PASSWORD/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{INSPECTION_ADMIN_ID}/$INSPECTION_ADMIN_ID/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{INSPECTION_ADMIN_PASSWORD}/$INSPECTION_ADMIN_PASSWORD/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{INSPECTION_DATABASE_ADMIN_ID}/$INSPECTION_DATABASE_ADMIN_ID/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{INSPECTION_DATABASE_ADMIN_PASSWORD}/$INSPECTION_DATABASE_ADMIN_PASSWORD/g" {} \;
find ../values -name "*.yaml" -exec sed -i "s/{INSPECTION_DATABASE_NAME}/$INSPECTION_DATABASE_NAME/g" {} \;

# 0. set provider type

if [[ "$PROVIDER_TYPE" == *standalone* ]]; then
  unset IMAGE_NAME[2]
fi

# 1. Create a project in Harbor
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

sudo podman login http://$REPOSITORY_URL --username $REPOSITORY_USERNAME --password $REPOSITORY_PASSWORD
curl -u $REPOSITORY_USERNAME:$REPOSITORY_PASSWORD -k http://$REPOSITORY_URL/api/v2.0/projects -XPOST --data-binary "{\"project_name\": \"$REPOSITORY_PROJECT_NAME\", \"public\": false}" -H "Content-Type: application/json" -i
sudo helm repo add $REPOSITORY_PROJECT_NAME --username $REPOSITORY_USERNAME --password $REPOSITORY_PASSWORD http://$REPOSITORY_URL/chartrepo/$REPOSITORY_PROJECT_NAME

# 2. Push the Container Platform Pipeline Image & Helm chart in Harbor
for IMAGE in ${IMAGE_NAME[@]}
do
  if [[ "$IMAGE" == *pipeline* ]]; then
  	sudo podman load -i ../images/$IMAGE-image.tar.gz
  	sudo podman tag localhost:5000/container-platform/$IMAGE $REPOSITORY_URL/$REPOSITORY_PROJECT_NAME/$IMAGE
  	sudo podman push $REPOSITORY_URL/$REPOSITORY_PROJECT_NAME/$IMAGE
  	sudo helm cm-push --username $REPOSITORY_USERNAME --password $REPOSITORY_PASSWORD ../charts/$IMAGE-chart.tgz $REPOSITORY_PROJECT_NAME
  elif [[ "IMAGE" == *sonarqube* ]]; then
    sudo helm cm-push --username $REPOSITORY_USERNAME --password $REPOSITORY_PASSWORD ../charts/$IMAGE-chart.tgz $REPOSITORY_PROJECT_NAME
  else
    sudo helm cm-push --username $REPOSITORY_USERNAME --password $REPOSITORY_PASSWORD ../charts/$IMAGE-chart.tgz $REPOSITORY_PROJECT_NAME
  fi
done

sudo helm repo update 


# 3. Deploy the Container Platform Pipeline
kubectl create namespace $NAMESPACE
kubectl create secret docker-registry $IMAGE_PULL_SECRET --docker-server=http://$REPOSITORY_URL --docker-username=$REPOSITORY_USERNAME --docker-password=$REPOSITORY_PASSWORD -n $NAMESPACE

for CHART_NAME in "${IMAGE_NAME[@]}"
do
  if [[ "$CHART_NAME" == *pipeline* ]]; then
    sudo helm install -f ../values/$CHART_NAME-values.yaml $CHART_NAME $REPOSITORY_PROJECT_NAME/$CHART_NAME --namespace $NAMESPACE
  elif [[ "$CHART_NAME" == *sonarqube* ]]; then
    sudo helm install -f ../values/$CHART_NAME-values.yaml $CHART_NAME $REPOSITORY_PROJECT_NAME/sonarqube --namespace $NAMESPACE
  else
    sudo helm install -f ../values/$CHART_NAME-values.yaml $CHART_NAME $REPOSITORY_PROJECT_NAME/postgresql --namespace $NAMESPACE
  fi
done

