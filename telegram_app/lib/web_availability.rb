# frozen_string_literal: true

require 'logger'
require 'telegram/bot'

require_relative 'services/add_website'
require_relative 'services/list_websites'

module Bots
  ##
  # Telegram base bot to process chat commands to add availability websites
  # check requests# frozen_string_literal: true
  #
  class WebAvailability
    attr_reader :bot, :user_message, :connection
    attr_accessor :user_data

    MAX_USER_LIMIT = 2
    START = 'Hello! Use /add_website to add a new website.'
    ADD_WEBSITE = 'Please send the URL of the website you want to add.'
    WEBSITE_ADDED = 'Thanks! The website has been added. You will be notified if the domain is down'
    INVALID = 'Invalid URL. Please enter a valid website.'
    INSTRUCTION = 'Send /add_website to add a website.'
    LIMIT_EXCEEDED = 'The website can not be saved. You exceeded the maximum amount'
    NO_WEBSITES = 'You dont have websites saved'

    def initialize(token, connection)
      @bot = Telegram::Bot::Client.new(token)
      @connection = connection
      @user_data = {}
    end

    def execute
      bot.listen do |message|
        process_message(message)
      rescue StandardError => e
        Logger.new($stdout).error(e.message)
      end
    end

    private

    def process_message(message)
      @user_message = message

      case message.text
      when '/start' then start
      when '/add_website' then add_website
      when '/list_websites' then list_websites
      else input_response
      end
    end

    def start
      send_message(START)
    end

    def add_website
      send_message(ADD_WEBSITE)
      user_data[user_message.chat.id] = :awaiting_url
    end

    def list_websites
      websites = user_websites.map { |website| "- #{website}" }

      message = websites.size > 0 ? "Your websites are: \n#{websites.join("\n")}" : NO_WEBSITES

      send_message(message)
    end

    def input_response
      if user_data[user_message.chat.id] == :awaiting_url
        validate_website
      else
        send_message(INSTRUCTION)
      end
    end

    def validate_website
      if user_message.text.start_with?('http://', 'https://')
        add_new_website
      else
        send_message(INVALID)
      end
    end

    def add_new_website
      user_data[user_message.chat.id] = nil

      if user_websites.size < MAX_USER_LIMIT
        save_website
        send_message(WEBSITE_ADDED)
      else
        send_message(LIMIT_EXCEEDED)
      end
    end

    def save_website
      config = { connection:, chat_id: user_message.chat.id, url: user_message.text }
      Services::AddWebsite.new(config).execute
    end

    def user_websites
      config = { connection:, chat_id: user_message.chat.id }
      Services::ListWebsites.new(config).execute
    end

    def send_message(text)
      bot.api.send_message(chat_id: user_message.chat.id, text:)
    end
  end
end
