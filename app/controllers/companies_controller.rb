# frozen_string_literal: true

class CompaniesController < ApplicationController
  def create
    company = Company.new(company_params)
    if company.save
      render_successful_response(:created) { CompanySerializer.new(company) }
    else
      render_error_response(company.errors.full_messages, :unprocessable_entity)
    end
  end

  def import
    data_processing_service = Companies::CsvDataProcessingService.new(params[:file])
    data_processing_service.call
    @import_service = Companies::ImportService.new(data_processing_service.company_data)
    @import_service.call

    render_successful_response(:created) { import_response }
  rescue Companies::CsvDataProcessingService::FileNotPresentError => e
    render_error_response(e.message, :bad_request)
  end

  private

  def company_params
    params.require(:company).permit(:name, :registration_number,
                                    addresses_attributes: %i[street city postal_code country])
  end

  def import_response
    {
      imported_companies: CompanySerializer.new(@import_service.imported_companies),
      failed_imports: @import_service.failed_imports
    }
  end
end
