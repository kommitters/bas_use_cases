# frozen_string_literal: true

require 'bas/bot/base'

module Implementation
  ##
  # The Implementation::PrepareStartInstanceFromConsole class collects user input to start
  # a BPMN process instance in Operaton. It gathers the `process_key`, `business_key`,
  # optional variables with automatic type inference, and a flag indicating whether to validate
  # the uniqueness of the business key. All this is stored in shared storage for later use.
  #
  # <b>Example</b>
  #
  #   write_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'operaton_created_instance',
  #     tag: 'PrepareStartInstance'
  #   }
  #
  #   shared_storage_reader = Bas::SharedStorage::Default.new
  #   shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })
  #
  #   Implementation::PrepareStartInstanceFromConsole
  #     .new({}, shared_storage_reader, shared_storage_writer)
  #     .execute
  #
  # <b>Expected Output</b>
  #   {
  #     process_key: 'Process_123abc',
  #     business_key: 'custom-key-001',
  #     variables: { foo: 'bar', amount: 100 },
  #     validate_business_key: true
  #   }
  #
  class PrepareStartInstanceFromConsole < ::Bas::Bot::Base
    def process
      show_intro

      {
        success: {
          process_key: prompt('🔑 Enter the process_key of the process to be instantiated:'),
          business_key: prompt('🏷️  Enter the business_key of the instance:'),
          variables: collect_variables,
          validate_business_key: confirm('🔍 Do you want to validate that NO other instance ' \
          'exists with the same business_key? (y/n):')
        }
      }.tap { show_success }
    end

    private

    def show_intro
      puts "\n📝 Data collection to create a process instance\n\n"
    end

    def show_success
      puts "\n✅ Data prepared successfully. It will be stored in the DB.\n"
    end

    def prompt(message)
      print "#{message} "
      $stdin.gets.chomp.strip
    end

    def confirm(message)
      print "#{message} "
      $stdin.gets.chomp.strip.downcase == 'y'
    end

    def collect_variables
      return {} unless confirm('➕ ¿Do you want to add variables? (y/n):')

      count = prompt('🔢 How many variables do you want to add?').to_i

      return {} if count <= 0 || count > 100

      variables = {}

      count.times do |i|
        key = prompt("🧷 Variable #{i + 1}: name:")
        raw_value = prompt("🧪 Variable #{i + 1}: value:")
        variables[key] = parse_value(raw_value)
      end

      variables
    end

    def parse_value(value)
      case value
      when /\A(true|false)\z/i then value.downcase == 'true'
      when /\A\d+\z/ then value.to_i
      when /\A\d+\.\d+\z/ then value.to_f
      else value
      end
    end
  end
end
