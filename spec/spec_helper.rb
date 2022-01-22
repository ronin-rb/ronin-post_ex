require 'rspec'
require 'simplecov'
require 'ronin/post_ex/version'

SimpleCov.start

RSpec.configure do |c|
  c.include Ronin::PostEx
end
