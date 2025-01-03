# frozen_string_literal: true

class AddressSerializer
  include Alba::Resource

  attributes :id, :street, :city, :postal_code, :country
end
