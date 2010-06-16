require 'helper'

class SystemTest < Test::Unit::TestCase

  include DeeplyValid

  context "a complex of validation" do
    setup do

      class MyValidations < DeeplyValid::Base
        define :person, {
          :id => token(32),
          :age => integer(1..100),
          :name => string(1..100),
          :department => {
            :name => any('sales', 'accounting', 'engineering'),
            :building => integer
          },
          :performace_reviews => array( structure(:review) ),
          :pension => value { |data| integer if data[:age] > 50 },
          :hobby => optional(string)
          
        }

        # This structure is referenced in the "person" structure
        define :review, {
          :author => string(1..100),
          :body => string(1..1024)
        }
      end

      @valid_person1 = {
        :id => "x"*32,
        :age => 22,
        :name => "Bob Jones",
        :department => {
          :name => "sales",
          :building => 33
        },
        :performace_reviews  => [
          { :author => "joe", :body => "a review" }, 
          { :author => "bill", :body => "another review" } 
        ]
      }

      # this person is over 50, so there's a value for pension
      @valid_person2 = {
        :id => "x"*32,
        :age => 61,
        :name => "Bob Jones",
        :pension => 666,
        :hobby => "boating",
        :department => {
          :name => "sales",
          :building => 33
        },
        :performace_reviews  => [
          { :author => "joe", :body => "a review" }, 
          { :author => "bill", :body => "another review" } 
        ]
      }

      # this person is under 50, and has a value for pension,
      # so the record is invalid.
      @invalid_person1 = {
        :id => "x"*32,
        :age => 22,
        :name => "Bob Jones",
        :pension => 666,
        :department => {
          :name => "sales",
          :building => 33
        },
        :performace_reviews  => [
          { :author => "joe", :body => "a review" }, 
          { :author => "bill", :body => "another review" } 
        ]
      }

      @invalid_person2 = {
        :id => "x"*32,
        :age => 32,
        :name => "Bob Jones",
        :department => {
          :name => "sales",
          :building => 33
        },
        :performace_reviews  => [
          { :author =>  11, :body => "a review" }, 
          { :author => "bill", :body => "another review" } 
        ]
      }

    end

    should "validate correctly" do
      assert MyValidations[:person].valid?(@valid_person1)
      assert MyValidations[:person].valid?(@valid_person2)
      assert !MyValidations[:person].valid?(@invalid_person1)
      assert !MyValidations[:person].valid?(@invalid_person2)
    end
    
  end

end
