# frozen_string_literal: true

module Companies
  class CsvDataProcessingService
    COMPANY_ATTRIBUTES = %w[name registration_number].freeze
    ADDRESS_ATTRIBUTES = %w[street city postal_code country].freeze

    attr_reader :companies

    class FileNotPresentError < StandardError; end

    def initialize(file)
      @file = file
      @companies = []
    end

    def call
      raise FileNotPresentError, 'file not present' if @file.blank?

      CSV.foreach(@file.path, headers: true) do |row|
        initialize_company_with_adress(row)
      end
    end

    private

    def initialize_company_with_adress(row)
      company_attributes = row.to_h.slice(*COMPANY_ATTRIBUTES)
      company_attributes['registration_number'] = company_attributes['registration_number']&.to_i
      addresses_attributes = row.to_h.slice(*ADDRESS_ATTRIBUTES)

      company = find_or_initialize_company(company_attributes)
      company.addresses.build(addresses_attributes)
    end

    def find_or_initialize_company(company_attributes)
      company = companies.find do |c|
        c.name == company_attributes['name'] && c.registration_number == company_attributes['registration_number']
      end
      unless company
        company = Company.new(company_attributes)
        companies << company
      end
      company
    end
  end
end
