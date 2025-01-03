# frozen_string_literal: true

source 'https://rubygems.org'

gem 'bootsnap', require: false
gem 'kamal', require: false
gem 'pg', '~> 1.1'
gem 'puma', '>= 5.0'
gem 'rails', '~> 8.0.1'
gem 'solid_cable'
gem 'solid_cache'
gem 'solid_queue'
gem 'thruster', require: false
gem 'tzinfo-data', platforms: %i[windows jruby]

gem 'alba', '~> 3.5'
gem 'csv'

group :development, :test do
  gem 'brakeman', require: false
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'
  gem 'factory_bot_rails', '~> 6.4'
  gem 'rspec-rails', '~> 7.0'
  gem 'rubocop-rails', '~> 2.28', require: false
end

group :test do
  gem 'shoulda-matchers', '~> 6.0'
end
