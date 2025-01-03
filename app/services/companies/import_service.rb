# frozen_string_literal: true

module Companies
  class ImportService
    ADDRESS_ATTRIBUTES = %w[street city postal_code country].freeze
    BATCH_SIZE = 300

    attr_reader :company_data, :imported_companies, :failed_imports

    def initialize(company_data)
      @company_data = company_data
      @imported_companies = []
      @failed_imports = []
    end

    def call
      company_data.each_slice(BATCH_SIZE) do |batch|
        import_batch(batch)
      end
    end

    private

    attr_writer :imported_companies, :failed_imports

    def import_batch(batch)
      Company.transaction do
        batch.each do |data|
          import_company(data)
        end
      end
    end

    def import_company(data)
      company = initialize_company_with_address(data)

      if company.save
        imported_companies << company
      else
        failed_imports << { name: company.name, registration_number: company.registration_number,
                            errors: company.errors.full_messages }
      end
    end

    def initialize_company_with_address(data)
      company = Company.find_or_initialize_by(name: data['name'], registration_number: data['registration_number'])
      company.addresses.build(data.slice(*ADDRESS_ATTRIBUTES))
      company
    end
  end
end
