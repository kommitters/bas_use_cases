# frozen_string_literal: true

require_relative 'services/list_websites'
require_relative 'services/remove_website'
require_relative 'services/add_website'
# rubocop:disable Metrics/ClassLength

# Module containing bot implementations for various use cases.
module Bots
  # Bot for managing website availability monitoring.
  # Supports commands to add, list, and remove websites using service classes.
  class WebAvailability
    attr_reader :user_data, :commands

    MAX_USER_LIMIT = 2
    COMMANDS = %w[add_website list_websites remove_website].freeze
    START_MESSAGE = "Hello! Use any of the available commands:\n#{COMMANDS.map { |cmd| "- /#{cmd}" }.join("\n")}".freeze
    ADD_WEBSITE_PROMPT = 'Please send the URL of the website you want to add.'
    WEBSITE_ADDED = 'Thanks! The website has been added. You will be notified if the domain is down'
    INVALID_URL = 'Invalid URL. Please enter a valid website.'
    LIMIT_EXCEEDED = 'The website cannot be saved. You exceeded the maximum amount.'
    NO_WEBSITES = 'You don’t have websites saved.'
    REMOVE_PROMPT = 'Send the number of the website you want to remove.'
    WEBSITE_REMOVED = 'The website was removed!'
    PROCESSING = 'Processing... 🏃‍♂️'
    # rubocop:enable Metrics/ClassLength

    def initialize(db_connection)
      @db_connection = db_connection
      @commands = {}
      @user_data = {}
    end

    def define_commands
      COMMANDS.each do |command|
        register_command("/#{command}", "#{command.tr('_', ' ').capitalize} action", command.to_sym)
      end
    end

    private

    def register_command(name, description, method_name)
      @commands[name] = {
        name:,
        description:,
        action: proc { |event, message, event_entity, instance|
          send(method_name, event, message, event_entity, instance)
        }
      }
    end

    def start(_event, _message, event_entity, bot_instance)
      bot_instance.send_message(event_entity, START_MESSAGE)
    end

    def custom_handler(_event, message, event_entity, bot_instance)
      bot_instance.send_message(event_entity, PROCESSING)
      case @user_data[event_entity.id]
      when :awaiting_url
        validate_website(message, event_entity, bot_instance)
      when :awaiting_remove_url
        validate_remove_option(message, event_entity, bot_instance)
      else
        bot_instance.send_message(event_entity, 'Send /add_website to add a website.')
      end
    end

    def validate_website(message, event_entity, bot_instance)
      if valid_url?(message)
        add_new_website(message, event_entity, bot_instance)
      else
        bot_instance.send_message(event_entity, INVALID_URL)
      end
    end

    def add_new_website(message, event_entity, bot_instance)
      @user_data[event_entity.id] = nil
      if user_websites(event_entity).size < MAX_USER_LIMIT
        save_website(message, event_entity)
        bot_instance.send_message(event_entity, WEBSITE_ADDED)
      else
        bot_instance.send_message(event_entity, LIMIT_EXCEEDED)
      end
    end

    def valid_url?(message)
      message.match?(%r{\Ahttp(s)?://\S+\.\S+}) ? message : "https://#{message}"
    end

    def save_website(message, event_entity)
      config = { connection: @db_connection, conversation_id: event_entity.id, url: valid_url?(message) }
      Services::AddWebsite.new(config).execute
    end

    def add_website(_event, _message, event_entity, bot_instance)
      bot_instance.send_message(event_entity, ADD_WEBSITE_PROMPT)
      @user_data[event_entity.id] = :awaiting_url
    end

    def list_websites(_event, _message, event_entity, bot_instance)
      bot_instance.send_message(event_entity, PROCESSING)
      websites = user_websites(event_entity)

      message = websites.any? ? "Your websites are:\n#{websites.map { |w| "- #{w}" }.join("\n")}" : NO_WEBSITES
      bot_instance.send_message(event_entity, message)
    end

    def remove_website(_event, _message, event_entity, bot_instance)
      bot_instance.send_message(event_entity, PROCESSING)
      websites = user_websites(event_entity)

      if websites.any?
        @user_data[event_entity.id] = :awaiting_remove_url
        options_message = "Active websites:\n#{websites.each_with_index.map { |w, i| "- #{i}: #{w}" }.join("\n")}"
        bot_instance.send_message(event_entity, "#{REMOVE_PROMPT}\n#{options_message}")
      else
        bot_instance.send_message(event_entity, NO_WEBSITES)
      end
    end

    def validate_remove_option(message, event_entity, bot_instance)
      index = message.to_i
      websites = user_websites(event_entity)

      if websites[index]
        delete_website(websites[index], event_entity)
        bot_instance.send_message(event_entity, WEBSITE_REMOVED)
      else
        bot_instance.send_message(event_entity, INVALID_URL)
      end
    end

    def delete_website(website, event_entity)
      config = { connection: @db_connection, website:, conversation_id: event_entity.id }
      Services::RemoveWebsite.new(config).execute
    end

    def user_websites(event_entity)
      config = { connection: @db_connection, conversation_id: event_entity.id }
      Services::ListWebsites.new(config).execute
    end
  end
end
