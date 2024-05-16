FROM mcr.microsoft.com/mssql/server:2022-latest

# Switch to root access to touch system directories
USER root

# Create a config directory
RUN mkdir -p /usr/config
WORKDIR /usr/config

# Bundle config source
COPY . /usr/config

# Grant permissions for to our scripts to be executable
RUN chmod +x /usr/config/entrypoint.sh
RUN chmod +x /usr/config/configure-db.sh

# Switch back to non-root user and run entrypoint script, starts SQL Server and runs initialization script
USER mssql
ENTRYPOINT ["./entrypoint.sh"]
