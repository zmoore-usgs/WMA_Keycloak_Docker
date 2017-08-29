# WMA_Keycloak_Docker
Default Docker files and Configuration for WMA Instances of Keycloak

## Local Usage

### Setup Docker Swarm (Using Docker Machine)

1. Choose a or create a new docker machine to serve as your swarm manager and on it run `docker swarm init`

    - If you get a warning about needing to pick an ip address pick one and follow the instructions.

2. SSH into your docker swarm maanger machine by running `docker-machine ssh <manager machine name>`

3. Create a new Docker Registry service on your swarm (images that are to-be deployed to a swarm cluster must be stored within a docker registry in order for the swarm to pull them) by running: `docker service create --name registory --publish 5000:5000 registry:2`

4. In order to push and pull images to and from your private registry it must be trsuted by your swarm manager. To do this edit the boot2docker profile by running `sudo vi /var/lib/boot2docker/profile` and adding `--insecure-registry <your docker swarm manager machine IP>:5000` as a new line in the `EXTRA_ARGS` section at the top of the file. After editing your `profile` file should look similar to this: 

    ```
    EXTRA_ARGS='
    --label provider=virtualbox
    --insecure-registry 192.168.99.101:5000
    '
    CACERT=/var/lib/boot2docker/ca.pem
    DOCKER_HOST='-H tcp://0.0.0.0:2376'
    DOCKER_STORAGE=aufs
    DOCKER_TLS=auto
    SERVERKEY=/var/lib/boot2docker/server-key.pem
    SERVERCERT=/var/lib/boot2docker/server.pem
    ```

5. Logout of the docker machine you SSH'd into, navigate to the project root directory, and follow the `Usage` steps below. 

    #### NOTE: If you are not using your default docker machine as your docker swarm manager then you will potentially run into a security error when trying to push built images to your registry. In order to avoid this you should either repeat step 4 on your default machine, or you should have your manager become your active machine when building the project. You can switch your active machine with the following command: `eval $(docker-machine env <machine name to activate>)` 

## Usage

1. In the project root directory create a `.env` file that contains values for each of the environment variables listed in the `Environment Variables` section. See the example `.env` file below:

    ```
    MYSQL_DATABASE=keycloak
    MYSQL_USERNAME=keycloak
    MYSQL_PASSWORD=password
    MYSQL_ROOT_PASSWORD=root_password
    MYSQL_PORT_3306_TCP_ADDR=192.168.99.100
    MYSQL_PORT_3306_TCP_PORT=3306
    KEYCLOAK_USER=admin
    KEYCLOAK_PASSWORD=admin
    KEYCLOAK_PORT=8080
    DOCKER_REGISTRY_HOST=192.168.99.101
    DOCKER_REGISTRY_PORT=5000
    ```

2. Open a bash shell (on Windows I use the Docker Quickstart Terminal from Docker Toolbox running through Git Bash) and navigate to the project root directory.

3. Setup a mysql database that is accessible by your docker swarm. This can be done using the included docker compose file `keycloak-db.yml`. This container can be started using `docker-compose -f keycloak-db.yml up`. Note that this will use the environment variables that you defined in the `.env` file to create the database, user, root user, and associated passwords. Once this database is created you may need to update the mysql address and port values in your `.env` file so that Keycloak can connect to it.

4. Run `docker-compose build` to build the WMA Keycloak docker image

5. Run `docker-compose push` to push the WMA Keycloak docker image to the registry specified in the `.env` file.

6. Copy the `.env` file and your pre-exported keycloak configuration JSON file (the included exmaple JSON file is `wma-keycloak-config.json`) to your swarm manager. This can be done using the following command (if using docker machine): `docker-machine scp <file> <manager machine name>:<destination file path with file name>`

7. If you are using docker-machine activate your swarm manager machine, otherwise SSH into your swarm manager machine.

8. Create a docker config object based on your exported keycloak configuration file by running `docker config create <name> <exported keycloak json file>`

9. Create the Keycloak service that is exposed on port 8080 by running the following command from within the direcotry that you copied the `.env` file and exported keycloak JSON file to: 

    ```docker service create --name keycloak -p 8080:8080 --config src=<config name> target="/opt/jboss/keycloak/wma-keycloak-config.json" --env-file .env <docker registry host>:<docker registry port>/wma_keycloak```

10. In a browser navigate to: `<Keycloak Container IP>:<KEYCLOAK_APP_PORT>/auth` and login to the administration console using the `KEYCLOAK_USER` and `KEYCLOAK_PASSWORD` credentials you provided in the `.env` file.

## Usage Notes

The docker file does *not* use currently use docker networking to link these containers together. Instead, the IP and Port (default 3306) of the database container should be provided in the `.env` file.

## Environment Variables
- MYSQL_DATABASE
    - The name of the database to create and connect to within MySQL

- MYSQL_USERNAME
    - The username to use when connecting to the MySQL database

- MYSQL_PASSWORD
    - The password to use when connecting to the MySQL database

- MYSQL_ROOT_PASSWORD
    - The password to use for the root user of the MySQL Database

- MYSQL_PORT_3306_TCP_ADDR
    - The host address of the MySQL database to connect to

- MYSQL_PORT_3306_TCP_PORT
    - The host port of the MySQL database to connect to

- KEYCLOAK_USER
    - The username to use for the keycloak admin account

- KEYCLOAK_PASSWORD
    - The password to use for the keycloak admin account

- KEYCLOAK_PORT
    - The port to expose the keycloak application on

- DOCKER_REGISTRY_HOST
    - The IP address of the machine running the docker registry service

- DOCKER_REGISTRY_PORT
    - THe port that the docker registry service is exposed on
