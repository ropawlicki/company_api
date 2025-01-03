# frozen_string_literal: true

module Companies
  class CsvDataProcessingService
    attr_reader :company_data

    class FileNotPresentError < StandardError; end

    def initialize(file)
      @file = file
      @company_data = []
    end

    def call
      raise FileNotPresentError, 'file not present' if @file.blank?

      CSV.foreach(@file.path, headers: true) do |row|
        row['registration_number'] = row['registration_number']&.to_i
        @company_data << row.to_h
      end
    end
  end
end
