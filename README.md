# WMA_Keycloak_Docker
Default Docker files and Configuration for WMA Instances of Keycloak

Based on Jboss Keycloak Server Base Image: https://github.com/jboss-dockerfiles/keycloak/tree/master/server

## Local Usage

NOTE: If you are only planning on using a loacl keycloak instance for testing and development purposes and you DO NOT need to use swarm capabilities then it is likely that all you will need to do is create a running instance of the basic keycloak image, rather than the WMA verison. Instructions for setting up a basic keycloak instance through Docker can be found here: https://hub.docker.com/r/jboss/keycloak-mysql/ 

### Setup Docker Swarm (Using Docker Machine)

1. Choose an existing or create a new docker machine to serve as your swarm manager and on it run `docker swarm init`

    - If you get a warning about needing to pick an ip address pick one and follow the instructions.

2. SSH into your docker swarm manager machine by running `docker-machine ssh <manager machine name>`

3. Create a new Docker Registry service on your swarm (images that are to-be deployed to a swarm cluster must be stored within a docker registry in order for the swarm to pull them) by running: `docker service create --name registry --publish 5000:5000 registry:2`

4. In order to push and pull images to and from your private registry it must be trsuted by your swarm manager. To do this edit the boot2docker profile by running `sudo vi /var/lib/boot2docker/profile` and adding `--insecure-registry <your docker swarm manager machine IP>:5000` as a new line in the `EXTRA_ARGS` section at the top of the file. After editing your `profile` file should look similar to this: 

    ```
    EXTRA_ARGS='
    --label provider=virtualbox
    --insecure-registry <docker-swarm machine IP>:5000
    '
    CACERT=/var/lib/boot2docker/ca.pem
    DOCKER_HOST='-H tcp://0.0.0.0:2376'
    DOCKER_STORAGE=aufs
    DOCKER_TLS=auto
    SERVERKEY=/var/lib/boot2docker/server-key.pem
    SERVERCERT=/var/lib/boot2docker/server.pem
    ```

5. Logout of the docker machine, restart the docker machine you SSH'd into, navigate to the project root directory, and follow the `Usage` steps below. 

    #### NOTE: If you are not using your default docker machine as your docker swarm manager then you will potentially run into a security error when trying to push built images to your registry. In order to avoid this you should either repeat step 4 on your default machine, or you should have your manager become your active machine when building the project. You can switch your active machine with the following command: `eval $(docker-machine env <machine name to activate>)` 

## DOI Root Cert

When it builds this docker file does a curl to pull the specified version of keycloak directly from the web. As a result of this, however, the DOI Root Cert must be included for the curl to succeed. This cert should be placed in the SSL subdirectory under the project root directory in place of the existing file.

## Usage

1. In the project root directory create a `.env` file that contains values for each of the environment variables listed in the `Environment Variables` section. See the example `.env` file below:

    ```
    MYSQL_DATABASE=keycloak
    MYSQL_PORT_3306_TCP_ADDR=<mysql database host IP>
    MYSQL_PORT_3306_TCP_PORT=3306
    KEYCLOAK_PORT=8080
    DOCKER_REGISTRY_HOST=<docker swarm manager machine IP>
    DOCKER_REGISTRY_PORT=5000
    ```

2. Open a bash shell (on Windows I use the Docker Quickstart Terminal from Docker Toolbox running through Git Bash) and navigate to the project root directory.

3. Copy the `.env` file and your pre-exported keycloak configuration JSON file (the included exmaple JSON file is `wma-keycloak-config.json`) to your swarm manager. This can be done using the following command (if using docker machine): `docker-machine scp <file> <manager machine name>:<destination file path with file name>`

4. SSH Into your Docker Swarm manager and create Docker Secrets for each of the secrets listed in the `Secrets` section below. Secrets can be created from a file using `docker secret create <name> <file>` or from STDIN using `echo "MySecretText" | docker secret create <name> -`.

5. Setup a mysql database that is accessible by your docker swarm. This container can be started as a service from the swarm manager using `docker service create --name keycloak_db --publish 3306:3306 --secret mysql_user --secret mysql_password --secret mysql_root_password --env MYSQL_DATABASE=keycloak --env MYSQL_USER_FILE=/run/secrets/mysql_user --env MYSQL_PASSWORD_FILE=/run/secrets/mysql_password --env MYSQL_ROOT_PASSWORD_FILE=/run/secrets/mysql_root_password`. Note that this will use the environment variables that you defined in the `.env` file and docker secrets to create the database, user, root user, and associated passwords. Once this database is created you may need to update the mysql address and port values in your `.env` file so that Keycloak can connect to it.

6. Log out of your docker swarm manager, back to the project root directory

7. Run `docker build -t wma_keycloak .` to build the WMA Keycloak docker image

8. Run `docker tag wma_keycloak <docker registry address>:<docker registry port>/wma_keycloak`

8. Run `docker push <docker registry address>:<docker registry port>/wma_keycloak` to push the WMA Keycloak docker image to the registry specifiedby the tag.

9. SSH Into your Docker Swarm manager and create the Keycloak service that is exposed on port 8080 by running the following command from within the direcotry that you copied the `.env` file and the exported keycloak JSON file to: 

    ```docker service create --name keycloak --publish 8080:8080 --secret mysql_user --secret mysql_password --secret keycloak_user --secret keycloak_password --secret keycloak_config --env MYSQL_DATABASE=keycloak --env MYSQL_PORT_3306_TCP_ADDR=192.168.99.102 --env MYSQL_PORT_3306_TCP_PORT=3306 --env MYSQL_USER_FILE=/run/secrets/mysql_user --env MYSQL_PASSWORD_FILE=/run/secrets/mysql_password --env KEYCLOAK_USER_FILE=/run/secrets/keycloak_user --env KEYCLOAK_PASSWORD_FILE=/run/secrets/keycloak_password --env KEYCLOAK_CONFIG_FILE=/run/secrets/keycloak_config <docker swarm manager IP>:5000/wma_keycloak```

10. In a browser navigate to: `<Keycloak Container IP>:<KEYCLOAK_APP_PORT>/auth` and login to the administration console using the `KEYCLOAK_USER` and `KEYCLOAK_PASSWORD` credentials you provided in the docker secrets.

## Usage Notes

The docker file does *not* use currently use docker networking to link these containers together. Instead, the IP and Port (default 3306) of the database container should be provided in the `.env` file.

## Environment Variables
- MYSQL_DATABASE
    - The name of the database to create and connect to within MySQL.
    - Note this is used in both the database compose file to create the database and the keycloak app compose file to connect keycloak to the database.

- MYSQL_PORT_3306_TCP_ADDR
    - The host address of the MySQL database to connect to.

- MYSQL_PORT_3306_TCP_PORT
    - The host port of the MySQL database to connect to.
    - Note this is used in both the database compose file to create the database listener and the keycloak app compose file to connect keycloak to the database.

- KEYCLOAK_PORT
    - The port to expose the keycloak application on.

- DOCKER_REGISTRY_HOST
    - The IP address of the machine running the docker registry service.

- DOCKER_REGISTRY_PORT
    - THe port that the docker registry service is exposed on.

## Secrets
- mysql_user
    - The username to use when connecting to the MySQL database. 
    - Note this is used in both the database compose file to create the user and the keycloak app compose file to connect keycloak to the database.

- mysql_password
    - The password to use when connecting to the MySQL database. 
    - Note this is used in both the database compose file to create the user and the keycloak app compose file to connect keycloak to the database.

- mysql_root_password
    - The password to use for the root user of the MySQL Database. 
    - Note that this is only used in the database compose file. If you are not creating the database using the included database compose file then this is not needed.

- keycloak_user
    - The username to use for the keycloak admin account.

- keycloak_password
    - The password to use for the keycloak admin account.

- keycloak_config
    - An exported Keycloak configuration JSON file to be imported into the keycloak instances created in the swarm.

## Below Sections Taken From https://github.com/jboss-dockerfiles/keycloak/tree/master/server

### Specify log level

When starting the Keycloak instance you can pass a number an environment variables to set log level for Keycloak, for example:

    docker run -e KEYCLOAK_LOGLEVEL=DEBUG jboss/keycloak

### Enabling proxy address forwarding

When running Keycloak behind a proxy, you will need to enable proxy address forwarding.

    docker run -e PROXY_ADDRESS_FORWARDING=true jboss/keycloak

## Other details

This image extends the [`jboss/base-jdk`](https://github.com/JBoss-Dockerfiles/base-jdk) image which adds the OpenJDK distribution on top of the [`jboss/base`](https://github.com/JBoss-Dockerfiles/base) image. Please refer to the README.md for selected images for more info.
