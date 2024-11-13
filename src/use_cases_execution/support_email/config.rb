module Config 
  REFRESH_TOKEN = ENV.fetch('SUPPORT_EMAIL_REFRESH_TOKEN'),
  CLIENT_ID = ENV.fetch('SUPPORT_EMAIL_CLIENT_ID'),
  CLIENT_SECRET = ENV.fetch('SUPPORT_EMAIL_CLIENT_SECRET'),
  TOKEN_URI = 'https://oauth2.googleapis.com/token',

  CONNECTION = {
    host: ENV.fetch('DB_HOST'),
    port: ENV.fetch('DB_PORT'),
    dbname: ENV.fetch('POSTGRES_DB'),
    user: ENV.fetch('POSTGRES_USER'),
    password: ENV.fetch('POSTGRES_PASSWORD')
  }
end