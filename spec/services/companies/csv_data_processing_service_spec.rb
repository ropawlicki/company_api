# frozen_string_literal: true

require 'rails_helper'

describe Companies::CsvDataProcessingService do
  subject(:service) { described_class.new(file) }

  let(:file) { fixture_file_upload('company_import.csv') }

  it 'creates company objects from csv file without ' do
    service.call

    expect(service.companies.first).to have_attributes(name: 'Example Co', registration_number: 123_456_789)
    expect(service.companies.second).to have_attributes(name: 'Another Co', registration_number: 987_654_321)
  end

  it 'creates addresses for companies' do
    service.call
    first_company = service.companies.first
    second_company = service.companies.second

    expect(first_company.addresses.first)
      .to have_attributes(street: '123 Main St', city: 'New York', postal_code: '10001', country: 'USA')
    expect(second_company.addresses.first)
      .to have_attributes(street: '789 Oak St', city: 'Chicago', postal_code: '60601', country: 'USA')
  end

  it 'raises error if file is not present' do
    service = described_class.new(nil)
    expect { service.call }.to raise_error(described_class::FileNotPresentError, 'file not present')
  end

  context 'when file contains company duplicates' do
    let(:file) { fixture_file_upload('duplicate_company_import.csv') }

    it 'creates only one company object' do
      service.call

      expect(service.companies.count).to eq(1)
      expect(service.companies.first).to have_attributes(name: 'Example Co', registration_number: 123_456_789)
    end

    it 'assigns address from duplicate company to existing company' do
      service.call
      company = service.companies.first

      expect(company.addresses.first)
        .to have_attributes(street: '123 Main St', city: 'New York', postal_code: '10001', country: 'USA')
      expect(company.addresses.second)
        .to have_attributes(street: '456 Elm St', city: 'Los Angeles', postal_code: '90001', country: 'USA')
    end
  end
end
