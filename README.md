# Portfolio Infra — Jenkins Server

This repository contains the Infrastructure as Code (IaC) for my Jenkins server, built on an old laptop running **Lubuntu**. The environment is orchestrated using **Docker** and **Docker Compose**, serving as a lab for my CI/CD and Terraform pipelines with **Jenkins**.

All host, database, reverse proxy, and application configurations are versioned and automated.

## Architecture

The server is divided into isolated containers communicating through dedicated Docker networks:

*   **PostgreSQL (`db-net`)**: Centralized database. Provides the `npm_db` databases and others.
*   **Nginx Proxy Manager (`proxy`)**: Visual reverse proxy and SSL certificate manager.
*   **Portainer (`proxy`)**: Graphical interface for Docker container management.
*   **Jenkins (`jenkins-net` + `db-net` + `proxy`)**: pipelines automation server, configured via Code (JCasC).

## How to Use

### Prerequisites
*   A host running Ubuntu, Debian, or derivatives (tested on Lubuntu).
*   `sudo` privileges to configure the operating system.
*   A `srvuser` with permissions to manage Docker.

### 1. Clone this Repository

```bash
git clone https://github.com/yagohp/portfolio-infra.git
cd portfolio-infra
```

### 2. Configure environment variables

```bash
cp .env.example .env # edit .env
```

### 3. Configure Host (first time using)

This command will install Docker, configure the firewall (UFW), create the networks for docker containers that this repo uses and give the right permissions for the user (use the Makefile).

```bash
make setup
```

This command below run the containers. It will raise the PostgreSQL, wait until it get ready and create the initial databases, then it will raise the app containers.

```bash
Make up
```

You can also use `Make down` or `Make restart`. All these commands are configured in [Makefile](./Makefile).

### 4. Services Access

With all containers up and running, you will be able to access through the server IP:

|Service        |Address       | Credentials                     |
|---------------|--------------|---------------------------------|
|Portainer      |http://IP:9443|Create on the first access       |
|Nginx Proxy Mgr|http://IP:81  |`admin@example.com` / `changeme` |
|Jenkins        |http://IP:8080|Command below                    |

Command to get Jenkins credentials (don't forget to change!):

```bash
docker exec jenkins-controller cat /var/jenkins_home/secrets/initialAdminPassword
```

The .env file also has the credentials variables for jenkins.

