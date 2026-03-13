require 'simplecov'
SimpleCov.start 'rails' do
  enable_coverage :branch
  minimum_coverage 80
  add_filter '/spec/'
  add_filter '/features/'
  add_filter '/config/'
  add_filter '/db/'
  add_filter '/vendor/'
end
