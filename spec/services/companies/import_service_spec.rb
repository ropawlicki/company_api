# frozen_string_literal: true

require 'rails_helper'

describe Companies::ImportService do
  subject(:service) { described_class.new(company_data) }

  let(:company_data) do
    [
      { 'name' => 'Example Co', 'registration_number' => 123_456_789, 'street' => '123 Main St', 'city' => 'New York',
        'postal_code' => '10001', 'country' => 'USA' }
    ]
  end

  it 'imports company with address' do
    service.call

    expect(Company.first.attributes).to include('name' => 'Example Co', 'registration_number' => 123_456_789)
    expect(Address.first.attributes).to include('street' => '123 Main St', 'city' => 'New York',
                                                'postal_code' => '10001', 'country' => 'USA')
  end

  context 'when data contains the same company with different addressess' do
    let(:company_data) do
      [
        { 'name' => 'Example Co', 'registration_number' => 123_456_789, 'street' => '123 Main St', 'city' => 'New York',
          'postal_code' => '10001', 'country' => 'USA' },
        { 'name' => 'Example Co', 'registration_number' => 123_456_789, 'street' => '456 Elm St',
          'city' => 'Los Angeles', 'postal_code' => '90001', 'country' => 'USA' }
      ]
    end

    it 'imports company with both addresses' do
      service.call

      expect(Company.first.addresses.first.attributes).to include('street' => '123 Main St', 'city' => 'New York',
                                                                  'postal_code' => '10001', 'country' => 'USA')
      expect(Company.first.addresses.last.attributes).to include('street' => '456 Elm St', 'city' => 'Los Angeles',
                                                                 'postal_code' => '90001', 'country' => 'USA')
    end
  end

  context 'when data contains two companies with the same registration number' do
    let(:company_data) do
      [
        { 'name' => 'Example Co', 'registration_number' => 123_456_789, 'street' => '123 Main St', 'city' => 'New York',
          'postal_code' => '10001', 'country' => 'USA' },
        { 'name' => 'Another Co', 'registration_number' => 123_456_789, 'street' => '456 Elm St',
          'city' => 'Los Angeles', 'postal_code' => '90001', 'country' => 'USA' }
      ]
    end

    it 'imports only the first company' do
      service.call

      expect(Company.first.attributes).to include('name' => 'Example Co')
      expect(Company.second).to be_nil
    end
  end

  describe 'invalid imports' do
    it 'does not import company with invalid data and records it' do
      company_data.first['name'] = nil
      service.call

      expect(Company.count).to eq(0)
      expect(service.failed_imports).to include({ name: nil, registration_number: 123_456_789,
                                                  errors: ["Name can't be blank"] })
    end

    it 'does not import company with invalid address data and records it' do
      company_data.first['street'] = nil
      service.call

      expect(Company.count).to eq(0)
      expect(service.failed_imports).to include({ name: 'Example Co', registration_number: 123_456_789,
                                                  errors: ["Addresses street can't be blank"] })
    end
  end
end
