module Config 
  CONNECTION = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    database: ENV.fetch('DB_NAME'),
    username: ENV.fetch('DB_USER'),
    password: ENV.fetch('DB_PASSWORD')
  }
end