# frozen_string_literal: true

require 'rspec'
require 'bas/shared_storage/postgres'

require_relative '../../../src/implementations/format_worklog'

ENV['WORKLOG_TABLE'] = 'WORKLOG_TABLE'

RSpec.describe Implementation::FormatWorklogs do
  let(:mocked_shared_storage) { instance_double(Bas::SharedStorage::Postgres) }
  let(:read_data) do
    {
      'worklogs' => {
        'Lorenzo Zuluaga' => [
          {
            'type' => 'Design',
            'hours' => 2,
            'activity' => 'Retrospective Meeting',
            'worklog_date' => '2025-05-22',
            'worklog_title' => nil,
            'detail' => 'Add feature a to the project'
          },
          {
            'type' => 'Dev',
            'hours' => 3,
            'activity' => 'Research Fund Opportunities',
            'worklog_date' => '2025-05-22',
            'worklog_title' => nil,
            'detail' => 'Add feature z to the project'
          }
        ],
        'Juan Camilo Muñoz Valencia' => [
          {
            'type' => 'Dev',
            'hours' => 3,
            'activity' => 'Research Fund Opportunities',
            'worklog_date' => '2025-05-22',
            'worklog_title' => nil,
            'detail' => 'Add feature y to the project'
          },
          {
            'type' => 'Dev',
            'hours' => 3,
            'activity' => 'Research Fund Opportunities',
            'worklog_date' => '2025-05-22',
            'worklog_title' => nil,
            'detail' => 'Add feature x to the project'
          }
        ]
      }
    }
  end

  before do
    allow(mocked_shared_storage).to receive(:read).and_return(
      instance_double(Bas::SharedStorage::Types::Read, data: read_data)
    )
    allow(mocked_shared_storage).to receive(:write).and_return(
      { 'status' => 'success', 'id' => 1 }
    )
    allow(mocked_shared_storage).to receive(:set_processed).and_return(nil)
    allow(mocked_shared_storage).to receive(:update_stage).and_return(true)
    allow(mocked_shared_storage).to receive(:set_in_process).and_return(nil)

    options = {
      person_section_template: '**<person_name>**',
      worklog_item_template: '- <hours>h: <detail>',
      no_activity_message: 'Sin detalle especificado'
    }

    @bot = Implementation::FormatWorklogs.new(options, mocked_shared_storage)
  end

  context '.execute' do
    before do
      bas_bot = instance_double(Implementation::FormatWorklogs)

      allow(Implementation::FormatWorklogs).to receive(:new).and_return(bas_bot)
      allow(bas_bot).to receive(:execute).and_return(
        {
          success: {
            notification: <<~NOTIFICATION.strip
              **Lorenzo Zuluaga**
              - 2h: Add feature a to the project
              - 3h: Add feature z to the project

              **Juan Camilo Muñoz Valencia**
              - 3h: Add feature y to the project
              - 3h: Add feature x to the project
            NOTIFICATION
          }
        }
      )
    end

    it 'executes the bas bot successfully' do
      expect(@bot.execute).not_to be_nil
    end
  end
end
