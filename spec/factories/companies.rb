# frozen_string_literal: true

FactoryBot.define do
  factory :company do
    name { 'Test Company' }
    registration_number { 1 }
  end
end
