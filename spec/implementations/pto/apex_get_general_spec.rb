# frozen_string_literal: true

require 'spec_helper'

ENV['APEX_OAUTH_BASE']    ||= 'https://apex.example.com'
ENV['APEX_API_BASE']      ||= 'https://api.example.com'
ENV['APEX_CLIENT_ID']     ||= 'client-id'
ENV['APEX_CLIENT_SECRET'] ||= 'client-secret'

require_relative '../../../src/utils/apex/apex_get_general'

RSpec.describe ApexClient do
  describe '.token' do
    it 'returns the access token on success' do
      response = instance_double(
        HTTParty::Response,
        code: 200,
        body: '{"access_token":"abc"}',
        parsed_response: { 'access_token' => 'abc' }
      )

      expected_options = {
        basic_auth: { username: ApexClient::APEX_CLIENT_ID, password: ApexClient::APEX_CLIENT_SECRET },
        headers: {
          'Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8',
          'Accept' => 'application/json; charset=UTF-8'
        },
        body: 'grant_type=client_credentials',
        open_timeout: ApexClient::OPEN_TIMEOUT,
        read_timeout: ApexClient::READ_TIMEOUT
      }

      expect(HTTParty).to receive(:post)
        .with("#{ApexClient::APEX_OAUTH_BASE}/oauth/token", expected_options)
        .and_return(response)

      expect(ApexClient.token).to eq('abc')
    end

    it 'raises on non-200 responses' do
      response = instance_double(HTTParty::Response, code: 401, body: 'nope', parsed_response: {})
      allow(HTTParty).to receive(:post).and_return(response)

      expect { ApexClient.token }.to raise_error(RuntimeError, /Token error \(401\): nope/)
    end
  end

  describe '.apex_get' do
    let(:token) { 't0ken' }

    it 'sanitizes the response body and enforces success codes' do
      raw_body = "result \xC3\x28".dup.force_encoding('BINARY')
      response = Struct.new(:code, :body, :parsed_response).new(200, raw_body, {})

      expect(HTTParty).to receive(:get).with(
        "#{ApexClient::APEX_API_BASE}/taskman_pto",
        hash_including(
          query: { foo: 'bar' },
          headers: {
            'Authorization' => "Bearer #{token}",
            'Accept' => 'application/json; charset=UTF-8'
          },
          open_timeout: ApexClient::OPEN_TIMEOUT,
          read_timeout: ApexClient::READ_TIMEOUT
        )
      ).and_return(response)

      sanitized = ApexClient.apex_get(token, 'taskman_pto', foo: 'bar')

      expect(sanitized.body.encoding).to eq(Encoding::UTF_8)
      expect(sanitized.body.valid_encoding?).to be(true)
    end

    it 'raises when the endpoint responds with non-2xx' do
      response = Struct.new(:code, :body, :parsed_response).new(500, 'boom', {})
      allow(HTTParty).to receive(:get).and_return(response)

      expect { ApexClient.apex_get(token, 'taskman_pto') }.to raise_error(
        RuntimeError,
        /APEX GET error \(500\): boom/
      )
    end
  end
end
