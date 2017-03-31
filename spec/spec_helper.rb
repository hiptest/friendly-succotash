# spec/spec_helper.rb
require 'rack/test'
require 'rspec'
require 'pry'

ENV['RACK_ENV'] = 'test'

require_relative '../app.rb'

module RSpecMixin
  include Rack::Test::Methods
  def app() App end
end

# For RSpec 2.x and 3.x
RSpec.configure { |c| c.include RSpecMixin }
