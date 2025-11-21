# frozen_string_literal: true

require 'dotenv/load'
require 'logger'
require 'httparty'
require 'json'
require 'fileutils'
require 'socket'
require 'time'

##
# Bas Logger Class
#
# Provides logging functionality for the application.
# Logs messages to both a file and the console.
# Optionally sends logs to a Grafana Loki instance if the URL is provided.
class BasLogger
  DEFAULT_LOG_FILE = File.expand_path('logs/bas.log', __dir__)
  MAX_LOG_FILES = 10
  MAX_LOG_SIZE  = 10 * 1024 * 1024

  BASE_LOGGER_INFO = {
    app: 'bas_use_cases',
    env: ENV.fetch('APP_ENV', 'development'),
    pid: Process.pid,
    logger: 'BasLogger',
    host: Socket.gethostname
  }.freeze

  def initialize(log_file: DEFAULT_LOG_FILE, loki_url: ENV['LOKI_URL'], loki_user: ENV['LOKI_USER'],
                 loki_password: ENV['LOKI_PASSWORD'])
    FileUtils.mkdir_p(File.dirname(log_file))

    @file_logger = Logger.new(log_file, MAX_LOG_FILES, MAX_LOG_SIZE)
    @console_logger = Logger.new($stdout)
    @loki_url = loki_url
    @loki_user = loki_user
    @loki_password = loki_password

    formatter = proc do |_severity, _datetime, _progname, msg|
      "#{msg}\n\n"
    end

    config_logger(formatter)
  end

  def info(msg) = log(:info, msg)
  def error(msg) = log(:error, msg)
  def warn(msg) = log(:warn, msg)

  private

  def config_logger(formatter)
    @file_logger.formatter = formatter
    @console_logger.formatter = formatter
    @file_logger.level = Logger::DEBUG
    @console_logger.level = Logger::DEBUG
  end

  def log(level, msg)
    serialized = serialize_to_structured_json(level, msg)
    @file_logger.send(level, serialized)
    @console_logger.send(level, serialized)

    return unless @loki_url

    log_to_manager = configure_log_message_event(msg, level, serialized)
    send_to_log_manager(log_to_manager)
  end

  def serialize_to_structured_json(level, msg)
    base = BASE_LOGGER_INFO.dup
    base[:timestamp] = Time.now.utc.iso8601
    base[:level] = level.to_s.upcase

    if msg.is_a?(Hash)
      base.merge!(msg)
    else
      base[:message] = msg.to_s
    end

    JSON.generate(base)
  end

  def send_to_log_manager(content)
    response = HTTParty.post(
      @loki_url, body: content.to_json,
                 headers: { 'Content-Type' => 'application/json' },
                 basic_auth: { username: @loki_user, password: @loki_password }
    )
    log_error_manager_response(response) unless response.success?
  rescue StandardError => e
    error_msg = "Error sending log to Loki: #{e.message}"
    @console_logger.error(error_msg)
    @file_logger.error(error_msg)
  end

  def configure_log_message_event(original_msg, level, serialized)
    labels = { app: BASE_LOGGER_INFO[:app], env: BASE_LOGGER_INFO[:env],
               host: BASE_LOGGER_INFO[:host], level: level.to_s.upcase }

    labels[:invoker] = original_msg[:invoker] if original_msg.is_a?(Hash) && original_msg[:invoker]

    {
      streams: [
        { stream: labels, values: [[(Time.now.to_f * 1_000_000_000).to_i.to_s, serialized]] }
      ]
    }
  end

  def log_error_manager_response(response)
    error_msg = "Loki responded with #{response.code}: #{response.body}"
    @console_logger.error(error_msg)
    @file_logger.error(error_msg)
  end
end

BAS_LOGGER = BasLogger.new
