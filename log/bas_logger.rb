# frozen_string_literal: true

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
  BASE_LOGGER_INFO = { # rubocop:disable Style/MutableConstant
    host: Socket.gethostname
  }

  def initialize(log_file: DEFAULT_LOG_FILE, loki_url: ENV['GRAFANA_LOKI_FULL_URL'])
    FileUtils.mkdir_p(File.dirname(log_file))

    @file_logger = Logger.new(log_file, MAX_LOG_FILES, MAX_LOG_SIZE)
    @console_logger = Logger.new($stdout)
    @loki_url = loki_url

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
    # send_to_log_manager(serialized, level) if @loki_url
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

  def send_to_log_manager(msg, level)
    payload = { streams: [
      {
        stream: { level: level, app: 'bas_use_cases' },
        values: [[(Time.now.to_f * 1_000_000_000).to_i.to_s, msg]]
      }
    ] }
    HTTParty.post(@loki_url, body: payload.to_json, headers: { 'Content-Type' => 'application/json' })
  rescue StandardError => e
    @console_logger.error("Error sending log to Loki: #{e.message}")
  end
end

BAS_LOGGER = BasLogger.new
