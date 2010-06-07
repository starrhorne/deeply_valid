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
          :performace_reviews => array( structure(:review) )
        }

        # This structure is referenced in the "person" structure
        define :review, {
          :author => string(1..100),
          :body => string(1..1024)
        }
      end

      @valid_person = {
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

      @invalid_person = {
        :id => "x"*32,
        :age => 22,
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
      assert MyValidations[:person].valid?(@valid_person)
      assert !MyValidations[:person].valid?(@invalid_person)
    end
    
  end

end
