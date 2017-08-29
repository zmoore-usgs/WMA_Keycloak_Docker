FROM jboss/keycloak-mysql:latest

ADD mlr-keycloak-config.json /opt/jboss/keycloak/

ENTRYPOINT [ "/opt/jboss/docker-entrypoint.sh" ]

CMD ["-b", "0.0.0.0", "--server-config", "standalone-ha.xml", "-Dkeycloak.import=/opt/jboss/keycloak/wma-keycloak-config.json"]