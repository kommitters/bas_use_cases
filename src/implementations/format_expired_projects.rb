# frozen_string_literal: true

require 'bas/bot/base'

module Implementation
  ##
  # The Implementation::FormatExpiredProjects class reads expired projects from a PostgresDB table,
  # formats them into a message using a template, and writes the formatted message back.
  #
  # <br>
  # <b>Example</b>
  #
  #   read_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'expired_projects',
  #     tag: 'ExpiredProjectsFromNotion'
  #   }
  #
  #   write_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'expired_projects',
  #     tag: 'FormatExpiredProjects'
  #   }
  #
  #   options = {
  #     template: 'The project <name> with ID <id> has expired!
  #     (<project_expiration_date>) and its status is still In progress :warning:'
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #   Implementation::FormatExpiredProjects.new(options, shared_storage).execute
  #
  class FormatExpiredProjects < Bas::Bot::Base
    PROJECT_ATTRIBUTES = %w[name id project_expiration_date].freeze

    def process
      return { success: { notification: '' } } if unprocessable_response

      projects_list = read_response.data['projects_expired']

      total_projects = projects_list.size

      header = "📋 *Expired Projects (#{total_projects} total)*\n\n"

      notification = projects_list.reduce(header) do |payload, project|
        "#{payload} #{build_template(PROJECT_ATTRIBUTES, project)}\n\n"
      end

      { success: { notification: } }
    end

    private

    def build_template(attributes, instance)
      template = process_options[:template]

      attributes.reduce(template) do |formatted, attr|
        value = fetch_attribute_value(attr, instance)
        formatted.gsub("<#{attr}>", value.to_s)
      end
    end

    def fetch_attribute_value(attribute, instance)
      case attribute
      when 'name'
        instance['title']
      when 'project_expiration_date'
        instance['deadline']
      else
        instance[attribute]
      end
    end
  end
end
