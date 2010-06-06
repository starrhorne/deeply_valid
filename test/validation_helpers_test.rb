require 'helper'

class ValidationHelpersTest < Test::Unit::TestCase

  include DeeplyValid

  context "a class with validation helpers" do

    setup do
      class Sample
        include DeeplyValid::ValidationHelpers
      end
    end

    context "token helper" do

      should "return correct regexp when no size specified" do
        assert Sample.token == /[0-9a-zA-Z_]/
      end

      should "return correct regexp when exact size specified" do
        assert Sample.token(32) == /[0-9a-zA-Z_]{32}/
      end

      should "return correct regexp when range size specified" do
        assert Sample.token(1..23) == /[0-9a-zA-Z_]{1,23}/
      end

    end

    context "string helper" do

      should "validate correctly, without size" do
        assert Sample.string.valid?("asdf")
      end

      should "validate correctly, with exact size" do
        assert Sample.string(4).valid?("asdf")
        assert !Sample.string(4).valid?("a")
      end

      should "validate correctly, with range size" do
        assert Sample.string(1..5).valid?("asdf")
        assert !Sample.string(3..5).valid?("a")
      end

    end

    context "integer helper" do

      should "validate correctly, without limit" do
        assert Sample.integer.valid?(123)
      end

      should "validate correctly, with exact limit" do
        assert Sample.integer(4).valid?(4)
        assert !Sample.integer(4).valid?(5)
      end

      should "validate correctly, with range limit" do
        assert Sample.integer(1..5).valid?(3)
        assert !Sample.integer(3..5).valid?(20)
      end

    end

    context "instance_of helper" do

      should "validate correctly" do
        assert Sample.instance_of(String).valid?("asdf")
        assert Sample.instance_of(Array).valid?([1,2,3])

        assert !Sample.instance_of(String).valid?([1,2,3])
        assert !Sample.instance_of(Array).valid?("asdf")
      end

    end


    context "json helper" do

      should "validate correctly" do
        assert Sample.json.valid?('{"x": "y"}')
        assert Sample.json.valid?('{"key": ["y", 1, 2, true, false]}')

        assert !Sample.json.valid?('{"x" "y"}')
        assert !Sample.json.valid?('{"key": {"y", 1, 2, true, false]}')
      end

    end


    context "any helper" do

      should "validate literals correctly" do
        assert Sample.any("a", "b", "c").valid?("c")
        assert Sample.any(1, 2, 3).valid?(2)

        assert !Sample.any("a", "b", "c").valid?("x")
        assert !Sample.any(1, 2, 3).valid?(20)
      end

      should "validate correctly using nested validations" do
        assert Sample.any(Validation.new("a"), Validation.new("b")).valid?("a")
        assert Sample.any(Validation.new(/[a-z]+/), Validation.new(/[0-9]+/)).valid?("12")

        assert !Sample.any(Validation.new("a"), Validation.new("b")).valid?("abc")
        assert !Sample.any(Validation.new(/^[a-z]+/), Validation.new(/^[0-9]+/)).valid?("Z12")
      end

    end

    context "all helper" do

      should "validate correctly" do
        assert Sample.all(Validation.new(/[a-z]+/), Validation.new(/[0-9]+/)).valid?("ab12")
        assert !Sample.all(Validation.new(/^[a-z]+/), Validation.new(/^[0-9]+/)).valid?("ab12")
      end

    end

    context "hash helper" do
      should "validate correctly" do
        assert Sample.hash({ (/^[a-z]+$/) => /^[0-9]+$/ }).valid?({ "abc" => "123" })
        assert Sample.hash({ (/^[a-z]+$/) => Validation.new { |d| d.is_a?(Array) } }).valid?({ "abc" => [] })
        assert Sample.hash({ (/^[a-z]+$/) => Validation.new { |d| d.is_a?(Array) } }).valid?({ "abc" => [], "cc" => [], "asd" => [] })

        assert !Sample.hash({ (/^[a-z]+$/) => /^[0-9]+$/ }).valid?({ "abc" => 123 })
        assert !Sample.hash({ (/^[a-z]+$/) => Validation.new { |d| d.is_a?(Array) } }).valid?({ "abc" => {} })
        assert !Sample.hash({ (/^[a-z]+$/) => Validation.new { |d| d.is_a?(Array) } }).valid?({ "abc" => [], "cde" => 123 })
      end
    end

    context "array helper" do
      should "validate correctly" do
        assert Sample.array(/^[a-z]+$/).valid?([ "abc", "def", "xyz" ])
        assert Sample.array(Validation.new { |d| d > 10 }).valid?([ 11, 12, 23 ])

        assert !Sample.array(/^[a-z]+$/).valid?([ "1abc", "def", "xyz" ])
        assert !Sample.array(Validation.new { |d| d > 10 }).valid?([ 11, 0, 12, 23 ])
      end
    end
    
  end

end
