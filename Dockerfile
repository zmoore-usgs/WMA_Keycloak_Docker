FROM jboss/keycloak-mysql:latest

ADD mlr-keycloak-config.json /opt/jboss/keycloak/

ENTRYPOINT [ "/opt/jboss/docker-entrypoint.sh" ]

CMD ["-b", "0.0.0.0", "-Dkeycloak.import=/opt/jboss/keycloak/mlr-keycloak-config.json"]