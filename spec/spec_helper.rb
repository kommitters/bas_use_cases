# frozen_string_literal: true

RSpec.configure do |config|
  config.before(:each) do
    allow(ENV).to receive(:fetch).and_return('mocked_value')
  end
end
