# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'
ENV.update(
  'OPERATON_API_BASE_URI' => 'https://operaton.test',
  'OPERATON_USER_ID' => 'test-user',
  'OPERATON_PASSWORD_SECRET' => 'test-secret'
)
