# DockerRecipeDb
A docker container and scripts to setup a testing database for bread recipes. Uses MSSQL Server 2022.

# Description of container and scripts
This project contains a dockerfile and some bash scripts based on prior work from Microsoft and partners to containerize SQL Server 2022 using the Linux Docker engine and non-root permissions. I have made some modifications to the bash scripts to:

- Use the environment local variable MSSQL_SA_PASSWORD instead of SA_PASSWORD as the later name has been deprecated. This variable is set when running the container using the current variable name.
- Move the database statment for checking the status to its own shell variable, so that the escapes aren't inline with the next bash statement. This is mostly for readability but was handy while troubleshooting the implementation so I've left it.
- Added custom T-SQL that runs after SQL Server startup to the designated file setup.sql. The commands added create a new login and user named testuser that is assigned to the sysadmin server-level role sysadmin. After that, the default sa account is disabled per security best practices guidance from Microsoft. Finally, a database named RecipeDb is created. These commands are sent to the server through sqlcmd using a single batch of statements.
- Switch between root and mssql users inside of a custom docker image to patch the example file provided through Microsoft. This image has also been changed to pull SQL Server 2022 (latest) instead of SQL Server 2017. Images for SQL Server 2019 and up currently start up as non-root automatically, whereas the SQL Server 2017 image is started as the root user by default, which can cause some security concerns.

# How to build this Docker image
1. Pull the git repository into a local directory. Here's how I'd do it with git:
```
git clone https://github.com/grc4kd/DockerRecipeDb.git
```
This should create a new folder using the repository name and pull all of the git refs and files into that folder, initializing a new local repository on the host machine.

2. Change directory and run a docker build command, providing a value for the MSSQL_SA_PASSWORD Docker environment variable. This could also be part of a Docker compose file, but there are more detailed instructions on building and deploying from bash script available from Microsoft at this time. I've kept the default image tag mssql-custom but that can be changed on the command line with the -t mysql-custom or --tag=mysql-custom options; just change the name. You may not need to use sudo if you are running the Docker Engine as a non-root user. I prefer to use sudo on my test bed but this can also be granted to a user using the `docker` suer group. *Warning*: The `docker` group grants root-level privileges to the user. For details on how this impacts security in your system, see [Docker Daemon Attach Surface](https://docs.docker.com/engine/security/#docker-daemon-attack-surface).
```
cd DockerRecipeDb
sudo docker build -t mssql-custom .
```

# How to run this Docker image
After building the image, you can run Microsoft SQL Server 2022 inside of a container using the standard documented syntax from Microsoft Learn. Here is an example that supplies a password on the command line for the sa user login. This login should be disabled after the image has finished running startup scripts and SQL commands. Use a unique and secret value for your own instance.
```
sudo docker run -e 'ACCEPT_EULA=Y' -e 'MSSQL_SA_PASSWORD=2n5mW15rSMpasspfh' -p 1433:1433 --name sql1 -d mssql-custom
```

The image will create a new user when it starts up named `testuser` with the password `testing-change-me-123`. The `docker run` command shown here will accept the EULA for the Developer edition of Microsoft SQL Server 2022, set the required environment variable `MSSQL_SA_PASSWORD`, make container traffic on port 1433 available on the same port using a local IP address (based on the Docker network configuration), set the container's name to `sql1` and run the newly built image `mssql-custom` in daemon mode, passing control off to a background process. 

I would recommend changing the `MSSQL_SA_PASSWORD` inside of the setup.sql script in the repository directory, but properly securing that information is outside of the scope of this README. For testing on a local machine, I leave this value as-is and set up the connection string information in user secrets for ASP.NET Core. A good option for cloud-hosted secrets would be Azure Key Vault or some encrypted password store that uses a secure channel to transmit and receive data. Try to ensure that sensitive information isn't persisted in memory after it is no longer in use, i.e., after the server has been started, after maintenance operations, or after CI/CD jobs have used this to log into the database server.

# What this gets you
Once the docker image is running inside of a container, the container can be addressed as a normal SQL Server by inspecting it's network address. The `setup.sql` script sets up a test user and login and an empty database, but could also be used to seed data using SQL statements. If needed, you can run other scripts by amending the `configure-db.sh` shell script and adding new calls to sqlcmd. A good option there would be to create a deployment script via an ORM like Entity Framework Core and to run that script at the end of the existing scripts so far. You can also deploy this with the Kubernetes and Docker Swarm orchestrators, further solidifying the Infrastructure as Code. I simply use the `docker run` command to spin up a database for testing at the moment. See the official Microsoft docs for information on backups, persisted volumes, and other information about SQL Server on Docker here: https://learn.microsoft.com 

Don't forget to have fun!