# frozen_string_literal: true

require 'rails_helper'

describe Companies::CsvDataProcessingService do
  subject(:service) { described_class.new(file) }

  let(:file) { fixture_file_upload('company_import.csv') }
  let(:expected_data) do
    [
      { 'name' => 'Example Co', 'registration_number' => 123_456_789, 'street' => '123 Main St', 'city' => 'New York',
        'postal_code' => '10001', 'country' => 'USA' },
      { 'name' => 'Example Co', 'registration_number' => 123_456_789, 'street' => '456 Elm St', 'city' => 'Los Angeles',
        'postal_code' => '90001', 'country' => 'USA' },
      { 'name' => 'Another Co', 'registration_number' => 987_654_321, 'street' => '789 Oak St', 'city' => 'Chicago',
        'postal_code' => '60601', 'country' => 'USA' },
      { 'name' => 'Another Co', 'registration_number' => nil, 'street' => '789 Oak St', 'city' => 'Chicago',
        'postal_code' => '60601', 'country' => 'USA' }
    ]
  end

  it 'creates company data hash from csv file' do
    service.call
    expect(service.company_data).to eq(expected_data)
  end

  it 'raises error if file is not present' do
    service = described_class.new(nil)
    expect { service.call }.to raise_error(described_class::FileNotPresentError, 'file not present')
  end
end
