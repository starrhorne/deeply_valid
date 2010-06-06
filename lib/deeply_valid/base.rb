module DeeplyValid


  #
  # By subclassing the base class, you can easily create 
  # groups of validations.
  #
  # == Example:
  #
  #   class Sample < DeeplyValid::Base
  #     define :regexp,     /[a-z]+/
  #     define :manual,     DeeplyValid::Validation.new { |d| d > 10 } 
  #     define :literal,    "x"
  #     define :structure,  { :key => "val" }
  #   end
  #
  #   Sample[:literal].valid?("x") # will return true
  #
  # == Example using ValidationHelpers
  #
  #   class Sample < DeeplyValid::Base
  #     define :name,       string(1..128)
  #     define :age,        integer(1..70)
  #     define :children,   hash( token => integer )
  #     define :colors,     array(any(:red, green, :blue))  
  #   end
  #
  class Base

    include ValidationHelpers

    class << self

      #
      # Add or create a validation object
      #
      # @param [Symbol] name A key that you'll use to retrieve the Validation
      # @param rule Any validation rule accepted by `DeeplyValid::Validation.new`
      #
      def define(name, rule)
        (@definitions ||= {})[name.to_sym] = rule.is_a?(Validation) ? rule : Validation.new(rule)
      end

      #
      # Retrieve a validation object
      #
      # @param [Symbol] the key used in `define`
      # @return [Validation] A validation object
      #
      def [](name)
        (@definitions ||= {})[name.to_sym]
      end

      def structure(name)
        Validation.new { |d| self[name.to_sym].valid?(d) }
      end

    end
  end
end
