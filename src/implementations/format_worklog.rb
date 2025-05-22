# frozen_string_literal: true

require 'bas/bot/base'
# require 'bas/utils/notion/request' # This is not needed in FormatWorklogs

module Implementation
  ##
  # The Implementation::FormatWorklogs class serves as a bot implementation to read worklogs from a
  # PostgresDB database, format them with a specific template, and write them on a PostgresDB
  # table with a specific format.
  #
  # <br>
  # <b>Example</b>
  #
  #   read_options = {
  #     connection:,
  #     db_table: "worklog",
  #     tag: "FetchWorklogsFromNotion"
  #   }
  #
  #   write_options = {
  #     connection:,
  #     db_table: "worklog",
  #     tag: "FormatWorklogs"
  #   }
  #
  #   options = {
  #     person_section_template: "**<person_name>**",
  #     worklog_item_template: "- <hours>h: <activity_or_type>", # New template for individual items
  #     no_activity_message: "Sin actividad especificada" # To handle default message
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #  Implementation::FormatWorklogs.new(options, shared_storage).execute
  #
  class FormatWorklogs < Bas::Bot::Base
    WORKLOG_ITEM_ATTRIBUTES = %w[hours activity].freeze

    # Process function to format the notification using a template
    #
    def process
      return { success: { notification: '' } } if unprocessable_response

      grouped_worklogs = read_response.data['worklogs'] || {}

      return { success: { notification: 'No se encontraron worklogs en el día de hoy.' } } if grouped_worklogs.empty?

      notification = grouped_worklogs.map do |person, worklogs|
        build_person_section(person, worklogs)
      end.join("\n\n")

      { success: { notification: } }
    end

    private

    # Builds a section for a single person's worklogs using templates.
    def build_person_section(person, worklogs)
      person_data = { 'person_name' => person }
      header = build_template(['person_name'], person_data, process_options[:person_section_template])

      items = worklogs.map do |worklog|
        item_data = worklog.dup
        item_data['activity'] = worklog['activity'] || process_options[:no_activity_message]
        build_template(WORKLOG_ITEM_ATTRIBUTES, item_data, process_options[:worklog_item_template])
      end.join("\n")

      "#{header}\n#{items}"
    end

    # Generic helper to build a string from a template and an instance's attributes.
    def build_template(attributes, instance, template_string)
      attributes.reduce(template_string) do |formatted_template, attribute|
        formatted_template.gsub("<#{attribute}>", instance[attribute].to_s)
      end
    end
  end
end
