# frozen_string_literal: true

class CompanySerializer
  include Alba::Resource

  attributes :id, :name, :registration_number

  many :addresses
end
