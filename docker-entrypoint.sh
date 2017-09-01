#!/bin/bash

#Set Keycloak Database Properties
if [ $MYSQL_PASSWORD ]; then
    MYSQL_PASSWORD_VAL=$MYSQL_PASSWORD
elif [ $MYSQL_PASSWORD_FILE ]; then
    MYSQL_PASSWORD_VAL=`cat $MYSQL_PASSWORD_FILE`
fi

if [ $MYSQL_USER ]; then
    MYSQL_USER_VAL=$MYSQL_USER
elif [ $MYSQL_USER_FILE ]; then
    MYSQL_USER_VAL=`cat $MYSQL_USER_FILE`
fi

#Modify Standalone Config
sed -e "s/REPLACE_ME_USER/$MYSQL_USER_VAL/g" $JBOSS_HOME/standalone/configuration/standalone.xml > temp.1.xml
sed -e "s/REPLACE_ME_PASSWORD/$MYSQL_PASSWORD_VAL/g" temp.1.xml > temp.2.xml
rm temp.1.xml
mv temp.2.xml $JBOSS_HOME/standalone/configuration/standalone.xml

#Modify HA Config
sed -e "s/REPLACE_ME_USER/$MYSQL_USER_VAL/g" $JBOSS_HOME/standalone/configuration/standalone-ha.xml > temp.1.xml
sed -e "s/REPLACE_ME_PASSWORD/$MYSQL_PASSWORD_VAL/g" temp.1.xml > temp.2.xml
rm temp.1.xml
mv temp.2.xml $JBOSS_HOME/standalone/configuration/standalone-ha.xml

#Set Keycloak Admin User Properties
if [ $KEYCLOAK_USER ]; then
    KEYCLOAK_USER_VAL=$KEYCLOAK_USER
elif [ $KEYCLOAK_USER_FILE ]; then
    KEYCLOAK_USER_VAL=`cat $KEYCLOAK_USER_FILE`
fi

if [ $KEYCLOAK_PASSWORD ]; then
    KEYCLOAK_PASSWORD_VAL=$KEYCLOAK_PASSWORD
elif [ $KEYCLOAK_PASSWORD_FILE ]; then
    KEYCLOAK_PASSWORD_VAL=`cat $KEYCLOAK_PASSWORD_FILE`
fi

if [ $KEYCLOAK_USER_VAL ] && [ $KEYCLOAK_PASSWORD_VAL ]; then
    keycloak/bin/add-user-keycloak.sh --user $KEYCLOAK_USER_VAL --password $KEYCLOAK_PASSWORD_VAL
fi

exec /opt/jboss/keycloak/bin/standalone.sh $@
exit $?
