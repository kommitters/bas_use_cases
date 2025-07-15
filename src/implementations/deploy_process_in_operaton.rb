# frozen_string_literal: true

require 'bas/bot/base'
require 'bas/utils/operaton/process_client'
require 'logger'

module Implementation
  ##
  # The Implementation::DeployProcess class serves as a bot to deploy a BPMN process to an Operaton instance.
  # It reads the deployment input (BPMN file path and deployment name)
  # from the shared storage and uses the Operaton REST API to deploy the diagram.
  #
  # <br>
  # <b>Example</b>
  #
  #   read_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'operaton_process_deployed',
  #     tag: 'PrepareDeployProcess'
  #   }
  #
  #   write_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'operaton_process_deployed',
  #     tag: 'DeployProcess'
  #   }
  #
  #   options = {
  #     operaton_base_url: 'http://localhost:8080/engine-rest'
  #   }
  #
  #   shared_storage = Bas::SharedStorage::Postgres.new({ read_options:, write_options: })
  #
  #   Implementation::DeployProcess.new(options, shared_storage).execute
  #
  # <br>
  # The input expected in shared storage (read from previous bot) should be a hash like:
  #
  #   {
  #     "file_path" => "path/to/diagram.bpmn",
  #     "deployment_name" => "OptionalDeploymentName"
  #   }
  #
  # If `deployment_name` is not provided, it defaults to `"DefaultDeployment"`.
  #
  class DeployProcess < ::Bas::Bot::Base
    def process
      data = read_response.data

      validation_error = validate_file_path(data['file_path'])
      return validation_error if validation_error

      deploy_process(data['file_path'], data['deployment_name'] || 'DefaultDeployment')
    end

    private

    def validate_file_path(file_path)
      return { error: 'file_path is required' } if file_path.nil? || file_path.strip.empty?
      return { error: "The file does not exist at the path: #{file_path}" } unless File.exist?(file_path)

      nil
    end

    def deploy_process(file_path, deployment_name)
      client = Utils::Operaton::ProcessClient.new(base_url: process_options[:operaton_base_url])

      Logger.new($stdout).info("🚀 Deploying process from: #{file_path} with deployment name: #{deployment_name}")
      response = client.deploy_process(file_path, deployment_name: deployment_name)

      Logger.new($stdout).info("✅ Process deployed successfully. ID: #{response['id']}")
      { success: response }
    rescue StandardError => e
      Logger.new($stdout).error("❌ Error deploying process: #{e.message}")
      { error: e.message }
    end
  end
end
