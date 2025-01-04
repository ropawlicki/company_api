# frozen_string_literal: true

require 'rails_helper'

describe Companies::ImportService do
  subject(:service) { described_class.new(import_companies) }

  let(:import_companies) { [company] }
  let(:company) { build(:company, name: 'Example Co', registration_number: 123_456_789) }
  let(:address) do
    build(:address, street: '123 Main St', city: 'New York', postal_code: '10001', country: 'USA', company:)
  end

  before do
    company.addresses << address
  end

  it 'imports company with address' do
    service.call

    expect(Company.first.attributes).to include('name' => 'Example Co', 'registration_number' => 123_456_789)
    expect(Address.first.attributes).to include('street' => '123 Main St', 'city' => 'New York',
                                                'postal_code' => '10001', 'country' => 'USA')
  end

  it 'overwrites existing company address' do
    create(:company, name: 'Example Co', registration_number: 123_456_789)
    create(:address, street: '789 Oak St', city: 'Chicago', postal_code: '60601', country: 'USA',
                     company: Company.first)
    service.call

    expect(Company.count).to eq(1)
    expect(Address.count).to eq(1)
    expect(Address.first.attributes).to include('street' => '123 Main St', 'city' => 'New York',
                                                'postal_code' => '10001', 'country' => 'USA')
  end

  describe 'invalid imports' do
    it 'does not import company with invalid data and records it' do
      company.name = nil
      service.call

      expect(Company.count).to eq(0)
      expect(service.failed_imports).to include({ name: nil, registration_number: 123_456_789,
                                                  errors: ["Name can't be blank"] })
    end

    it 'does not import company with invalid address data and records it' do
      address.street = nil
      service.call

      expect(Company.count).to eq(0)
      expect(service.failed_imports).to include({ name: 'Example Co', registration_number: 123_456_789,
                                                  errors: ["Addresses street can't be blank"] })
    end
  end
end
