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
            'worklog_title' => nil
          },
          {
            'type' => 'Dev',
            'hours' => 3,
            'activity' => 'Research Fund Opportunities',
            'worklog_date' => '2025-05-22',
            'worklog_title' => nil
          }
        ],
        'Juan Camilo Muñoz Valencia' => [
          {
            'type' => 'Dev',
            'hours' => 3,
            'activity' => 'Research Fund Opportunities',
            'worklog_date' => '2025-05-22',
            'worklog_title' => nil
          },
          {
            'type' => 'Dev',
            'hours' => 3,
            'activity' => 'Research Fund Opportunities',
            'worklog_date' => '2025-05-22',
            'worklog_title' => nil
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
      worklog_item_template: '- <hours>h: <activity>',
      no_activity_message: 'Sin actividad especificada'
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
              - 2h: Retrospective Meeting
              - 3h: Research Fund Opportunities

              **Juan Camilo Muñoz Valencia**
              - 3h: Research Fund Opportunities
              - 3h: Research Fund Opportunities
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
