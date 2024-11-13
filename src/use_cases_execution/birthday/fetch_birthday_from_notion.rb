# frozen_string_literal: true

require 'logger'

require_relative '../../implementations/fetch_birthday_from_notion'

# Configuration
options = {
  process_options: {
    database_id: '5ba9d10982b542f1b6d9c3a25f693886',
    secret: 'secret_1bzN0RI03gmJRayvAe4Mq2Qzs6d8TmMTvgREzUDlgUj'
  },
  write_options: {
    connection: {
      host: 'bas_db',
      port: 5432,
      dbname: 'bas',
      user: 'admin',
      password: 'WzxuH87TADlaGd49VGcP'
    },
  db_table: "use_cases",
  tag: "FetchBirthdaysFromNotion"
  },
}

# Process bot
begin
  bot = Bot::FetchBirthdaysFromNotion.new(options)

  result = bot.execute
  puts result.inspect
rescue StandardError => e
  Logger.new($stdout).info(e.message)
end
