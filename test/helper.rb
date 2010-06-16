require 'rubygems'
require 'test/unit'
require 'shoulda'
begin; require 'turn'; rescue LoadError; end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'deeply_valid'

class Test::Unit::TestCase
  class << self

    def should_validate_all(data)
      data.each do |d|
        should "validate #{ d.inspect }" do
          assert @validation.valid?(d)
        end
      end
    end


    def should_not_validate_any(data)
      data.each do |d|
        should "not validate #{ d.inspect }" do
          assert !@validation.valid?(d)
        end
      end
    end

  end
end
