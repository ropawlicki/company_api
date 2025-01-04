# frozen_string_literal: true

module Companies
  class ImportService
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
        batch.each { |company_object| import_company(company_object) }
      end
    end

    def import_company(company_object)
      company = initialize_company_with_address(company_object)

      if company.save
        imported_companies << company
      else
        failed_imports << { name: company.name, registration_number: company.registration_number,
                            errors: company.errors.full_messages }
      end
    end

    def initialize_company_with_address(company_object)
      company = Company.find_or_initialize_by(name: company_object.name,
                                              registration_number: company_object.registration_number)
      company.addresses = company_object.addresses
      company
    end
  end
end
