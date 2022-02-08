#!/bin/bash
K8S_MASTER_NODE_IP="{k8s master node public ip}"                 # Kubernetes master node public ip
PROVIDER_TYPE="{container platform pipeline provider type}"        # Container platform pipeline provider type (Please enter 'standalone' or 'service')
CF_API_URL="https:\/\/{paas-ta-api-domain}"                      # e.g) https:\/\/api.10.0.0.120.nip.io, PaaS-TA API Domain, PROVIDER_TYPE=service 인 경우 입력

# deployment config
NAMESPACE="paas-ta-container-platform-pipeline"
IMAGE_TAGS="latest"
IMAGE_PULL_POLICY="Always"
IMAGE_PULL_SECRET="cp-secret"

IMAGE_NAME=(
"paas-ta-container-platform-pipeline-api"
"paas-ta-container-platform-pipeline-common-api"
"paas-ta-container-platform-pipeline-broker"
"paas-ta-container-platform-pipeline-ui"
"paas-ta-container-platform-pipeline-inspection-api"
"paas-ta-container-platform-pipeline-jenkins"
"paas-ta-container-platform-pipeline-config-server"
"paas-ta-container-platform-postgresql"
"paas-ta-container-platform-sonarqube"
)

SERVICE_TYPE="NodePort"
SERVICE_PROTOCOL="TCP"

### persistent ###
PERSISTENT_STORAGE_CLASS_NAME="paas-ta-container-platform-nfs-storageclass"

#keycloak
KEYCLOAK_URL="http:\/\/${K8S_MASTER_NODE_IP}:32710" #include http:\/\/, if apply TLS, https:\/\/
KEYCLOAK_ADMIN_ID="admin"
KEYCLOAK_ADMIN_PASSWORD="admin"
KEYCLOAK_CP_REALM="container-platform-realm"
KEYCLOAK_IDENTITY_PROVIDER_ID="paas-ta-container-platform-saml-idp"
KEYCLOAK_CLUSTER_ADMIN_GROUP="paas-ta-container-platform-cluster-admin"
KEYCLOAK_CLUSTER_ADMIN_ROLE="paas-ta-container-platform-cluster-admin-role"
KEYCLOAK_CP_CLIENT_ID="container-platform-client"
KEYCLOAK_CP_CLIENT_SECRET="c7de06cf-01c4-4d45-b462-595fcddd19fe"

#database
DATABASE_URL="${K8S_MASTER_NODE_IP}:31306"
DATABASE_USER_ID="cp-admin"
DATABASE_USER_PASSWORD="Paasta!2022"

#repository
REPOSITORY_PROJECT_NAME="paas-ta-container-platform-pipeline-repository"
REPOSITORY_URL="${K8S_MASTER_NODE_IP}:30002" # do not include http://
REPOSITORY_USERNAME="admin"
REPOSITORY_PASSWORD="Harbor12345"


### inspection-server ###
INSPECTION_ADMIN_ID="admin"
INSPECTION_ADMIN_PASSWORD="admin"
INSPECTION_DATABASE_ADMIN_ID="sonar"
INSPECTION_DATABASE_ADMIN_PASSWORD="sonar@2020"
INSPECTION_DATABASE_NAME="inspection"
