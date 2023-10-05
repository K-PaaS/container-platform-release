#!/bin/bash
K8S_MASTER_NODE_IP="{k8s master node public ip}"                 # Kubernetes master node public ip
PROVIDER_TYPE="{container platform pipeline provider type}"        # Container platform pipeline provider type (Please enter 'standalone' or 'service')
CF_API_URL="https:\/\/{api-domain}"                      # e.g) https:\/\/api.10.0.0.120.nip.io, API Domain, PROVIDER_TYPE=service 인 경우 입력

# deployment config
NAMESPACE="container-platform-pipeline"
IMAGE_TAGS="latest"
IMAGE_PULL_POLICY="Always"
IMAGE_PULL_SECRET="cp-secret"

IMAGE_NAME=(
"container-platform-pipeline-api"
"container-platform-pipeline-common-api"
"container-platform-pipeline-broker"
"container-platform-pipeline-ui"
"container-platform-pipeline-inspection-api"
"container-platform-pipeline-jenkins"
"container-platform-pipeline-config-server"
"container-platform-postgresql"
"container-platform-sonarqube"
)

SERVICE_TYPE="NodePort"
SERVICE_PROTOCOL="TCP"

### persistent ###
PERSISTENT_STORAGE_CLASS_NAME="container-platform-nfs-storageclass"

#keycloak
KEYCLOAK_URL="http:\/\/${K8S_MASTER_NODE_IP}:32710" #include http:\/\/, if apply TLS, https:\/\/
KEYCLOAK_ADMIN_ID="admin"
KEYCLOAK_ADMIN_PASSWORD="admin"
KEYCLOAK_CP_REALM="container-platform-realm"
KEYCLOAK_IDENTITY_PROVIDER_ID="container-platform-saml-idp"
KEYCLOAK_CLUSTER_ADMIN_GROUP="container-platform-cluster-admin"
KEYCLOAK_CLUSTER_ADMIN_ROLE="container-platform-cluster-admin-role"
KEYCLOAK_CP_CLIENT_ID="container-platform-client"
KEYCLOAK_CP_CLIENT_SECRET="c7de06cf-01c4-4d45-b462-595fcddd19fe"

#database
DATABASE_URL="${K8S_MASTER_NODE_IP}:31306"
DATABASE_USER_ID="cp-admin"
DATABASE_USER_PASSWORD="Paasta!2022"

#repository
REPOSITORY_PROJECT_NAME="container-platform-pipeline-repository"
REPOSITORY_URL="${K8S_MASTER_NODE_IP}:30002" # do not include http://
REPOSITORY_USERNAME="admin"
REPOSITORY_PASSWORD="Harbor12345"


### inspection-server ###
INSPECTION_ADMIN_ID="admin"
INSPECTION_ADMIN_PASSWORD="admin"
INSPECTION_DATABASE_ADMIN_ID="sonar"
INSPECTION_DATABASE_ADMIN_PASSWORD="sonar@2020"
INSPECTION_DATABASE_NAME="inspection"
