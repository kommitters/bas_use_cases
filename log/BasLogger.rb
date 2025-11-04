require 'logger'
require 'httparty'
require 'json'

class BasLogger
  def initialize(log_file: 'log/bas.log', loki_url: ENV['GRAFANA_LOKI_FULL_URL'])
    @file_logger = Logger.new(log_file)
    @console_logger = Logger.new($stdout)
    @loki_url = loki_url
  end

  def info(msg)
    log(:info, msg)
  end

  def error(msg)
    log(:error, msg)
  end

  def warn(msg)
    log(:warn, msg)
  end

  private

  def log(level, msg)
    serialized_msg = serialize_message(msg)
    @file_logger.send(level, serialized_msg)
    @console_logger.send(level, serialized_msg)
    send_to_logger_manager(serialized_msg, level) if @loki_url
  end

  def serialize_message(msg)
    msg.is_a?(Hash) || msg.is_a?(Array) ? msg.to_json : msg.to_s
  end

  def send_to_logger_manager(msg, level)
    payload = {
      streams: [
        {
          stream: { level: level, app: 'bas_use_cases' },
          values: [[(Time.now.to_f * 1_000_000_000).to_i.to_s, msg]]
        }
      ]
    }
    HTTParty.post(@loki_url, body: payload.to_json, headers: { 'Content-Type' => 'application/json' })
  rescue => e
    @console_logger.error("Error sending log to Loki: #{e.message}")
  end
end

BAS_LOGGER = BasLogger.new