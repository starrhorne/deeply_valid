require 'helper'

class BaseTest < Test::Unit::TestCase

  include DeeplyValid

  context "a subclass of Base" do
    setup do
      class Sample < DeeplyValid::Base
        define :self_reference, structure(:regexp)
        define :regexp, /[a-z]+/
        define :manual, DeeplyValid::Validation.new { |d| d > 10 } 
        define :literal, "x"
        define :hash, { :key => "val" }
        define :nested_self_reference, structure { |data| structure(:regexp) }
      end
    end

    [[:regexp, "abc"], [:manual, 11], [:literal, "x"], [:hash, {:key => "val"}]].each do |r, d|
      should "make #{ r } accessible via []" do
        assert Sample[r]
      end

      should "wrap #{ r } in Validation class" do
        assert Sample[r].is_a?(Validation)
      end

      should "validate #{ r }" do
        assert Sample[r].valid?(d)
      end

    end

    should "Handle self reference" do
      assert Sample[:self_reference]
      assert Sample[:self_reference].valid?("abc")
      assert !Sample[:self_reference].valid?("123")
    end

    should "Handle nested self-reference" do
      assert Sample[:nested_self_reference]
      assert Sample[:nested_self_reference].valid?("abc")
      assert !Sample[:nested_self_reference].valid?("123")
    end
    
  end

end
