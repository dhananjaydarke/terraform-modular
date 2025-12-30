FROM postgres:16-alpine
COPY seed.sql /seed.sql
CMD ["sh", "-c", "PGPASSWORD=\"$DB_PASSWORD\" psql -h \"$DB_HOST\" -p \"${DB_PORT:-5432}\" -U \"$DB_USER\" -d \"$DB_NAME\" -f /seed.sql"]
