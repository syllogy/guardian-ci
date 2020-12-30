# Starts postgres and applies migrations

export POSTGRES_PORT=5432 POSTGRES_USER=component POSTGRES_PASSWORD=component POSTGRES_DB=component

docker-compose up -d postgres

until docker-compose exec postgres pg_isready; do
  sleep 1
done

docker-compose up -d migrate

echo "export POSTGRES_URL=postgres://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost:$POSTGRES_PORT/$POSTGRES_DB?sslmode=disable" >> "$BASH_ENV"