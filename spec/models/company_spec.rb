# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Company, type: :model do
  subject { build(:company) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_most(256) }
  it { should validate_presence_of(:registration_number) }
  it { should validate_uniqueness_of(:registration_number) }
  it { should have_many(:addresses).dependent(:destroy) }

  it 'accepts nested attributes for addresses' do
    expect(subject).to accept_nested_attributes_for(:addresses)
  end
end
