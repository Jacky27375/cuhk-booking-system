require 'simplecov'
require 'simplecov-cobertura'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::CoberturaFormatter
])

SimpleCov.start 'rails' do
  enable_coverage :branch
  minimum_coverage 80
  add_filter '/spec/'
  add_filter '/features/'
  add_filter '/config/'
  add_filter '/db/'
  add_filter '/vendor/'

  add_group 'Analytics', 'app/controllers/analytics_controller.rb'
  add_group 'Controllers', 'app/controllers'
  add_group 'Models', 'app/models'
  add_group 'Helpers', 'app/helpers'
  add_group 'Mailers', 'app/mailers'
  add_group 'Views', 'app/views'
end
