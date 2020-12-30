# Starts rabbit and applies migrations

RABBIT_PORT=5672 RABBIT_MGMT_PORT=15672 docker-compose up -d rabbit

until docker-compose exec rabbit rabbitmqctl await_startup --timeout 60; do
  sleep 1
done

echo "export RABBIT_URL='amqp://guest:guest@localhost:5672'" >> "$BASH_ENV"
echo "export RABBIT_MGMT_URL='http://guest:guest@localhost:15672'" >> "$BASH_ENV"