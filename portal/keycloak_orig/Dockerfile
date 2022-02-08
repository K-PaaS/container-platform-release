FROM docker.io/jboss/keycloak:15.0.2

COPY tls-key/* /etc/x509/https/
COPY container-platform/ /opt/jboss/keycloak/themes/container-platform/
COPY {CONTAINER_PLATFORM_PORTAL_PROVIDER_TYPE}-realm.json /opt/jboss/keycloak/imports/container-platform-realm-realm.json

CMD ["-Dkeycloak.migration.action=import","-Dkeycloak.migration.provider=singleFile","-Dkeycloak.migration.file=/opt/jboss/keycloak/imports/container-platform-realm-realm.json","-Dkeycloak.migration.strategy=IGNORE_EXISTING"]

