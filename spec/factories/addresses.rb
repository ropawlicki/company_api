# frozen_string_literal: true

FactoryBot.define do
  factory :address do
    company { create(:company) }
    street { 'Test Street' }
    city { 'Test City' }
    postal_code { '53100' }
    country { 'Test Country' }
  end
end
