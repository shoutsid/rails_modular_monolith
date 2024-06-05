# frozen_string_literal: true

# TODO: replace with a real connector pattern

if !Rails.env.test? && defined?(Rails::Server) && ENV['SETUP_KAFKA_CONNECTOR'] == 'true'
  # Register the connector once the kafka-connector service is running

  `curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" connect:8083/connectors/ -d @- << EOF
    {
      "name": "ollama-outbox-connector",
      "config": {
        "connector.class": "io.debezium.connector.postgresql.PostgresConnector",
        "tasks.max": "1",
        "plugin.name": "pgoutput",
        "database.hostname": "#{ENV.fetch('PG_HOST', nil)}",
        "database.port": "#{ENV.fetch('PG_PORT', nil)}",
        "database.user": "#{ENV.fetch('PG_USER', nil)}",
        "database.password": "#{ENV.fetch('PG_PASSWORD', nil)}",
        "database.dbname": "ollama_#{Rails.env}",
        "database.server.name": "#{ENV.fetch('KAFKA_CONNECT_DB_SERVER_NAME', nil)}_ollama",
        "schema.include.list": "public",
        "table.include.list": "public.ollama_outboxes",
        "tombstones.on.delete": "false",
        "slot.name" : "ollama",
        "slot.drop_on_stop": "#{Rails.env.development?}"
      }
    }
  EOF`

  # To check if the connector registered properly
  # - Run `curl -i -X GET -H "Accept:application/json" localhost:8083/connectors/user-access-outbox-connector`
  # result = `curl -i -X GET -H "Accept:application/json" localhost:8083/connectors/user-access-outbox-connector`
  # puts result
  # # TODO: suggestion to run this with docker-compose to check if everything is working and if not raise an error.
  # if result != 'whatever'
  #   raise "The connector is not registered properly"
  # end
end
