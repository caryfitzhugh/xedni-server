require "rubygems"
require "bundler/setup"
Bundler.require(:default)
require 'minitest/autorun'
require 'ruby-debug'

puts "Will test against Xedni server at port 11456..."

class TestXedni < MiniTest::Unit::TestCase
  def test_saving_and_retrieving
    # Want to test that we can fire off 1000 creates
    # Then do a read
    # and the read will see all 1000 of the created elements
  end
  private
  def create(id,opts={})
  end
  def read(id)
  end
end
