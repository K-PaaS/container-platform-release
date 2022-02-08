#!/bin/bash
K8S_MASTER_NODE_IP="{k8s master node public ip}"                 # Kubernetes master node public ip
PROVIDER_TYPE="{container platform source control provider type}"        # Container platform source control provider type (Please enter 'standalone' or 'service')

NAMESPACE="paas-ta-container-platform-source-control"
IMAGE_TAGS="latest"
IMAGE_PULL_POLICY="Always"
IMAGE_PULL_SECRET="cp-secret"

IMAGE_NAME=(
"paas-ta-container-platform-source-control-api"
"paas-ta-container-platform-source-control-manager"
"paas-ta-container-platform-source-control-broker"
"paas-ta-container-platform-source-control-ui"
)

SERVICE_TYPE="NodePort"
SERVICE_PROTOCOL="TCP"

PERSISTENT_STORAGE_CLASS_NAME="paas-ta-container-platform-nfs-storageclass"

KEYCLOAK_URL="http:\/\/${K8S_MASTER_NODE_IP}:32710" #include http:\/\/, if apply TLS, https:\/\/
KEYCLOAK_ADMIN_ID="admin"
KEYCLOAK_ADMIN_PASSWORD="admin"
KEYCLOAK_CP_REALM="container-platform-realm"
KEYCLOAK_IDENTITY_PROVIDER_ID="paas-ta-container-platform-saml-idp"
KEYCLOAK_CLUSTER_ADMIN_GROUP="paas-ta-container-platform-cluster-admin"
KEYCLOAK_CLUSTER_ADMIN_ROLE="paas-ta-container-platform-cluster-admin-role"
KEYCLOAK_CP_CLIENT_ID="container-platform-client"
KEYCLOAK_CP_CLIENT_SECRET="c7de06cf-01c4-4d45-b462-595fcddd19fe"

DATABASE_URL="${K8S_MASTER_NODE_IP}:31306"
DATABASE_USER_ID="cp-admin"
DATABASE_USER_PASSWORD="Paasta!2022"

REPOSITORY_URL="${K8S_MASTER_NODE_IP}:30002"
REPOSITORY_USERNAME="admin"
REPOSITORY_PASSWORD="Harbor12345"
REPOSITORY_PROJECT_NAME="paas-ta-container-platform-source-control-repository"


