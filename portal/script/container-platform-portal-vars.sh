# COMMON VARIABLE (Please change the values of the four variables below.)
K8S_MASTER_NODE_IP="203.255.255.117"                                            # Kubernetes Master Node Public IP
K8S_AUTH_BEARER_TOKEN="eyJhbGciOiJSUzI1NiIsImtpZCI6InJCcUZfYU1fbDBLLUk2TGRqbGRCWF9MZ3Ztc1FURGhNNm1aRzdNa2E3VWcifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJrOHNhZG1pbi10b2tlbi1reHRtdiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJrOHNhZG1pbiIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImMwNGM2MWM3LWQ4YWEtNGU1OC1iMTg1LTQxN2NmYjhlYTE1ZSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTprOHNhZG1pbiJ9.mMbyIx14UwdkzTXn8FeN9T4wYuk8lVGdekz5YwRceUBL6wJUhU1jLYvJI7hloMrOYO94rOxVtFlQ5OQILMZ4WDcOvrBIn5AuhbTpdAtF0XS14NaAxcuo3oAhfEooNMPq_IG6-68TS9ErpIINjY4jm4iJPCs0B9R6nveyYu5E8zG_PP2I2OB8uk87exDkN25UbYisukp7GNJ1_8zaRKTJwoBagLkmCXb-y1miRORkvZ0EAES34LRrLKR3usqEvH0PgqePXQuvX_zojixFwIRMDhbLRksAeXgM5ovvHwkuQBxTtbcwt4wXh0PTuqZI71wVsUtvSWHVzSZ16bAWf-RUVg"                                             # Kubernetes Authorization Bearer Token
NFS_SERVER_IP="10.100.1.131"                                                             # NFS Server IP
PROVIDER_TYPE="standalone"                                   # Container Platform Portal Provider Type (Please enter 'standalone' or 'service')



# The belows are the default values.
# If you change the values below, there will be a problem with the deploy. Please keep the values.
# K8S
K8S_API_SERVER_PORT="6443"                                                                   # Kubernetes api server port

# STORAGECLASS
NFS_NAMESPACE="nfs-storageclass"                                                             # NFS storageclass namespace
NFS_STORAGECLASS_NAME="container-platform-nfs-storageclass"                          # NFS storageclass name

# SERVICE
SERVICE_TYPE="NodePort"                                                                      # Service type in kubernetes
SERVICE_PROTOCOL="TCP"                                                                       # Service protocol in kubernetes

# HARBOR REPOSITORY
REPOSITORY_NAMESPACE="harbor"                                                                # Repository namespace
REPOSITORY_URL="10.100.1.161:30002"                                                   # Repository url
REPOSITORY_USERNAME="admin"                                                                  # Repository admin username (e.g. admin)
REPOSITORY_PASSWORD="Harbor12345"                                                            # Repository admin password (e.g. Harbor12345)
REPOSITORY_PROJECT_NAME="container-platform-repository"                              # Repository project name
IMAGE_TAGS="latest"                                                                          # Image tag
IMAGE_PULL_POLICY="Always"                                                                   # Image pull policy
IMAGE_PULL_SECRET="container-platform-image-secret"                                  # Image pull secret

# MARIADB
DATABASE_NAMESPACE="mariadb"                                                                 # Database namespace
DATABASE_URL="container-platform-mariadb.mariadb.svc.cluster.local:3306"             # Database url
DATABASE_USER_ID="cp-admin"                                                                  # Database user name (e.g. cp-admin)
DATABASE_USER_PASSWORD="Paasta!2022"                                                         # Database user password (e.g. Paasta!2022)

# KEYCLOAK
KEYCLOAK_NAMESPACE="keycloak"                                                                # Keycloak namespace
KEYCLOAK_URL="https:\/\/203.255.255.117.nip.io:32710"                                          # Keycloak url (include http:\/\/, if apply TLS, https:\/\/)
KEYCLOAK_DB_VENDOR="mariadb"                                                                 # Keycloak database vendor
KEYCLOAK_DB_SCHEMA="keycloak"                                                                # Keycloak database schema
KEYCLOAK_ADMIN_USERNAME="admin"                                                              # Keycloak admin username (e.g. admin)
KEYCLOAK_ADMIN_PASSWORD="admin"                                                              # Keycloak admin password (e.g. admin)
KEYCLOAK_SESSIONS_COUNT="2"                                                                  # Keycloak sessions count
KEYCLOAK_LOG_LEVEL="DEBUG"                                                                   # Keycloak log level
KEYCLOAK_CP_REALM="container-platform-realm"                                                 # Keycloak realm for container platform portal
KEYCLOAK_CP_CLIENT_ID="container-platform-client"                                            # Keycloak client id for container platform portal
KEYCLOAK_CP_CLIENT_SECRET="c7de06cf-01c4-4d45-b462-595fcddd19fe"                             # Keycloak client secret for container platform portal

# CONTAINER-PLATFORM-PORTAL
CONTAINER_PLATFORM_PORTAL_NAMESPACE="container-platform-portal"                      # Container platform portal namespace
CONTAINER_PLATFORM_PORTAL_PROVIDER_TYPE="container-platform-portal-$PROVIDER_TYPE"   # Container platform portal provider type

# CONTAINER-PLATFORM-SERVICE
CONTAINER_PLATFORM_PIPELINE_NAMESPACE="container-platform-pipeline"                  # Container platform service pipeline namespace
CONTAINER_PLATFORM_SOURCE_CONTROL_NAMESPACE="container-platform-source-control"      # Container platform service source control namespace
CONTAINER_PLATFORM_DEFAULT_INGRESS_NAMESPACE="ingress-nginx"                                 # Container platform default ingress namespace
