# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Companies', type: :request do
  describe 'POST /create' do
    let(:expected_company_keys) { %w[id name registration_number addresses] }
    let(:expected_address_keys) { %w[id street city postal_code country] }

    let(:valid_params) do
      {
        company: {
          name: 'Example Co',
          registration_number: 123_456_789,
          addresses_attributes: [
            {
              street: '123 Main St',
              city: 'New York',
              postal_code: '10001',
              country: 'USA'
            }
          ]
        }
      }
    end

    it 'renders a successful response' do
      post companies_path, params: valid_params
      expect(response).to have_http_status(:created)
    end

    it 'creates a company and address with expected attributes' do
      post companies_path, params: valid_params
      company = Company.first
      address = company.addresses.first

      expect(company.attributes).to include('name' => 'Example Co', 'registration_number' => 123_456_789)
      expect(address.attributes).to include('street' => '123 Main St', 'city' => 'New York', 'postal_code' => '10001',
                                            'country' => 'USA')
    end

    it 'renders company and address attributes in the response' do
      post companies_path, params: valid_params
      parsed_response_body = JSON.parse(response.body)['data']

      expect(parsed_response_body.keys).to match_array(expected_company_keys)
      expect(parsed_response_body['addresses'].first.keys).to match_array(expected_address_keys)
    end

    it 'renders an unprocessable entity response when company params are invalid' do
      invalid_company_params = valid_params.deep_merge(company: { name: nil })
      post companies_path, params: invalid_company_params
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'renders an unprocessable entity response when address params are invalid' do
      invalid_address_params = valid_params.deep_merge(company: { addresses_attributes: [{ street: nil }] })
      post companies_path, params: invalid_address_params
    end
  end

  describe 'POST /import' do
    let(:csv_file) { fixture_file_upload(fixture_file_upload('company_import.csv')) }
    let(:expected_import_company_keys) { %w[id name registration_number addresses] }
    let(:expected_failed_import_keys) { %w[name registration_number errors] }

    it 'renders a successful response' do
      post import_companies_path, params: { file: csv_file }
      expect(response).to have_http_status(:created)
    end

    it 'imports companies and addresses from csv file' do
      post import_companies_path, params: { file: csv_file }
      company = Company.first
      address = company.addresses.first

      expect(company.attributes).to include('name' => 'Example Co', 'registration_number' => 123_456_789)
      expect(address.attributes).to include('street' => '123 Main St', 'city' => 'New York', 'postal_code' => '10001',
                                            'country' => 'USA')
    end

    it 'renders imported companies in the response' do
      post import_companies_path, params: { file: csv_file }
      parsed_response_body = JSON.parse(response.body)['data']

      expect(parsed_response_body['imported_companies'].first.keys).to match_array(expected_import_company_keys)
      expect(parsed_response_body['failed_imports'].first.keys).to match_array(expected_failed_import_keys)
    end

    it 'renders a bad request response when file is not present' do
      post import_companies_path
      expect(response).to have_http_status(:bad_request)
    end
  end
end
