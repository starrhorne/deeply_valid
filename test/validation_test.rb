require 'helper'

class ValidationTest < Test::Unit::TestCase

  include DeeplyValid

  context "A regexp validation for alphanumeric strings" do

    setup do
      @validation = Validation.new(/^[a-zA-Z0-9]*$/)
    end
    
    should_validate_all %w[ abc a91 192 AbC A912D ljasd122 asdDLf9sS ]

    should_not_validate_any %w[ !asdlj s82_s saf.dfd 1u0od#s ]
    
  end

  context "A block validation for numbers > 5 and < 20" do

    setup do
      @validation = Validation.new { |d| d > 5 && d < 20 }
    end
    
    should_validate_all (6..19)

    should_not_validate_any ((0..5).to_a + (20..25).to_a)
    
  end

  context "A structure validation for {:key => 'alnum'} using nested validation" do
    setup do
      rule = { :key => Validation.new(/^[a-zA-Z0-9]*$/) }
      @validation = Validation.new(rule)
    end

    should_validate_all([
      {:key => "123"},
      {:key => "1shj23"},
      {:key => "123KJHjhksj1"},
      {:key => "12askjfh12aBn3"},
    ])

    should_not_validate_any([
      {:key => "12##3"},
      {:xkey => "1sh  j23"},
      {:key => "123K_a s@#JHjhksj1"},
      {:ke => "12askjfh1*)}2aBn3"},
    ])

  end

  context "A structure validation for {:key => 'alnum'} using regexp" do
    setup do
      rule = { :key => /^[a-zA-Z0-9]*$/ }
      @validation = Validation.new(rule)
    end

    should_validate_all([
      {:key => "123"},
      {:key => "1shj23"},
      {:key => "123KJHjhksj1"},
      {:key => "12askjfh12aBn3"},
    ])

    should_not_validate_any([
      {:sdkey => "12##3"},
      {"key" => "1sh  j23"},
      {:key => "123K_a s@#JHjhksj1"},
      {:key => "12askjfh1*)}2aBn3"},
    ])

  end

  context "A nested structure validation for {:token => alnum, :person => { :name => string, :age => int }}" do
    setup do

      rule = {
        :token => /^[a-zA-Z0-9]*$/, 
        :person => { 
          :name => Validation.new { |d| d.is_a?(String) }, 
          :age => Validation.new { |d| d.is_a?(Integer) && d > 0 } 
        }
      }

      @validation = Validation.new(rule)
    end

    should_validate_all([
      {:token => "token234", :person => { :name => "Bob Jones", :age => 22 }},
      {:token => "tjgkh", :person => { :name => "Bob", :age => 1 }, :extra => true},
      {:token => "token234", :person => { :name => "", :age => 2002 }},
    ])

    should_not_validate_any([
      {:person => { :name => "Bob Jones", :age => 22 }},
      {:token => "t__jgkh", :person => { :name => "Bob", :age => 0 }},
      {:token => "token234", :person => { :namex => "", :age => 2002 }},
      {"token" => "token234", :person => { :name => "", :age => 2002 }},
    ])

  end

  context "A structure validation for {:key => nil}" do
    setup do
      rule = { :key => nil, :bogus => 1 }
      @validation = Validation.new(rule)
    end

    should_validate_all([
      {:bogus => 1}
    ])

    should_not_validate_any([
      {:key => false, :bogus => 1},
      {:key => true, :bogus => 1},
      {:key => nil, :bogus => 1},
      {:key => "sesame", :bogus => 1},
    ])

  end

  context "A structure with an optional validation" do
    setup do
      rule = { :key => Validation.new(1, :optional => true) }
      @validation = Validation.new(rule)
    end

    should_validate_all([
      {:key => 1},
      {}
    ])

    should_not_validate_any([
      {:key => 2},
      {:key => nil},
      {:key => false}
    ])

  end

end
