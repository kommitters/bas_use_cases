# frozen_string_literal: true

require 'bas/bot/base'

module Implementation
  ##
  # The Implementation::PrepareDeployProcess class collects from the user
  # the necessary data to deploy a BPMN process (file path and deployment name),
  # and stores it in the shared storage for later use by the DeployProcess bot.
  #
  # <b>Example</b>
  #
  #   write_options = {
  #     connection: Config::CONNECTION,
  #     db_table: 'operaton_process_deployed',
  #     tag: 'PrepareDeployProcess'
  #   }
  #
  #   shared_storage_reader = Bas::SharedStorage::Default.new
  #   shared_storage_writer = Bas::SharedStorage::Postgres.new({ write_options: })
  #
  #   Implementation::PrepareDeployProcess
  #     .new({}, shared_storage_reader, shared_storage_writer)
  #     .execute
  #
  # <b>Expected Output</b>
  #   {
  #     file_path: 'path/to/diagram.bpmn',
  #     deployment_name: 'MyDeploymentName'
  #   }
  #
  class PrepareDeployProcess < ::Bas::Bot::Base
    def process
      puts "\n📝 Data collection for BPMN process deployment\n\n"

      print '📂 Enter the path of the BPMN file: '
      file_path = $stdin.gets.strip
      return { error: 'file_path is required' } if file_path.empty?
      return { error: "The file does not exist at the path: #{file_path}" } unless File.exist?(file_path)

      print "📛 Enter the name of the deployment (or leave blank to use 'DefaultDeployment'): "
      deployment_name = $stdin.gets.strip
      deployment_name = 'DefaultDeployment' if deployment_name.empty?

      puts "\n✅ Data prepared successfully. It will be stored in the shared storage.\n"

      { success: { file_path:, deployment_name: } }
    end
  end
end
