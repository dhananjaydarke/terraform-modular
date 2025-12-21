FROM mcr.microsoft.com/mssql-tools
COPY seed.sql /seed.sql
CMD /opt/mssql-tools/bin/sqlcmd -S $DB_HOST,$DB_PORT -U $DB_USER -P $DB_PASSWORD -d $DB_NAME -i /seed.sql
