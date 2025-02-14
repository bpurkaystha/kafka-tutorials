CREATE SOURCE CONNECTOR inventory WITH (
  'connector.class'          = 'PostgresSource',
  'name'                     = 'recipe-postgres-customer_journey',
  'kafka.api.key'            = '<my-kafka-api-key>',
  'kafka.api.secret'         = '<my-kafka-api-secret>',
  'connection.host'          = '<my-database-endpoint>',
  'connection.port'          = '5432',
  'connection.user'          = 'postgres',
  'connection.password'      = '<my-database-password>',
  'db.name'                  = '<db-name>',
  'table.whitelist'          = 'pages',
  'timestamp.column.name'    = 'created_at',
  'output.data.format'       = 'JSON',
  'db.timezone'              = 'UTC',
  'tasks.max'                = '1'
);
