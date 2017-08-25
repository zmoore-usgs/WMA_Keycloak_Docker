# WMA_Keycloak_Docker
Default Docker files and Configuration for WMA Instances of Keycloak

## Usage

1. In the project root directory create a `.env` file that contains values for each of the environment variables listed below. See the example `.env` file below.

    ```
    KEYCLOAK_DB_NAME=keycloak
    KEYCLOAK_DB_USER=keycloak
    KEYCLOAK_DB_PASSWORD=password
    KEYCLOAK_DB_ROOT_PASSWORD=root_password
    KEYCLOAK_DB_HOST=192.168.99.100
    KEYCLOAK_DB_PORT=3306
    KEYCLOAK_ADMIN_USER=admin
    KEYCLOAK_ADMIN_PASSWORD=admin
    KEYCLOAK_APP_PORT=8080
    ```

2. Run `docker-compose up`

3. In a browser navigate to: `<Keycloak Container IP>:<KEYCLOAK_APP_PORT>/auth` and login to the administration console using the `KEYCLOAK_ADMIN_USER` and `KEYCLOAK_ADMIN_PASSWORD` credentials.

## Usage Notes

The docker compose file creates both a database container (based on MySQL) and the Keycloak application container.

The docker file does *not* use currently use docker networking to link these containers together. Instead, the IP and Port (default 3306) of the database container should be provided.

## Environment Variables
- KEYCLOAK_DB_NAME
    - The name of the database to create and connect to within MySQL

- KEYCLOAK_DB_USER
    - The username to use when connecting to the MySQL database

- KEYCLOAK_DB_PASSWORD
    - The password to use when connecting to the MySQL database

- KEYCLOAK_DB_ROOT_PASSWORD
    - The password to use for the root user of the MySQL Database

- KEYCLOAK_DB_HOST
    - The host address of the MySQL database to connect to

- KEYCLOAK_DB_PORT
    - The host port of the MySQL database to connect to

- KEYCLOAK_ADMIN_USER
    - The username to use for the keycloak admin account

- KEYCLOAK_ADMIN_PASSWORD
    - The password to use for the keycloak admin account

- KEYCLOAK_APP_PORT
    - The port to expose the keycloak application on
