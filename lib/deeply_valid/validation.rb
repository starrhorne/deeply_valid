module DeeplyValid

  #
  # The Validation lets us define validations using 
  # several different kinds of rules.
  #
  class Validation

    attr_accessor :options

    #
    # The initializer defines the conditions that will
    # satasfy this validation.
    #
    # @param [Regexp] rule    When `rule` is a `Regexp` we use `=~` to validate
    # @param [Hash]   rule    When `rule` is a `Hash`, then `valid_structure?` does the validation 
    # @param [Object] rule    When `rule` is any other non-nil object, use `==` to validate
    # @param [Proc]   &block  An optional block, which will take one param and return true or false
    #
    def initialize(rule = nil, options = {}, &block)

      if rule.nil? && !block_given?
        raise "No validation rule specified"
      end

      @options = options
      @rule = rule
      @block = block
    end

    #
    # Validate data by regexp
    #
    # @param [String] String to be validated
    #
    def valid_pattern?(data)
      !!(data =~ @rule)
    end

    #
    # Recursively validate a complex data structure
    # For now, only hashes are supported.
    #
    # == Example Rules:
    #
    #   { :key => /regexp/ }
    #   { :key => Validation.new { |d| d > 20 } }
    #   { :key => "literal" }
    #   { :key => { :key2 => /regexp/ }, :key2 => "literal" }
    #
    # As you see, rules can be nested arbitrarily deep.
    # The validaions work like you would expect.
    #
    #   { :key => /[a-z]+/ } will validate { :key => "a" } 
    #   { :key => /[a-z]+/ } will NOT validate { :key => 123 } 
    #
    # @param [Hash] Hash fragment to be validated
    # @param [Hash] Optional rules for validating hash fragment
    # @return true if valid, false if invalid
    #
    def valid_structure?(data, fragment_rule = nil)
      (fragment_rule || @rule).all? do |k, v|

        v = v.call(@data) if v.is_a?(Proc)

        if v.is_a?(Validation)
          (v.options[:optional] && !data.has_key?(k)) || v.valid?(data[k])

        elsif v.is_a?(Regexp)
          !!(data[k] =~ v)

        elsif v.is_a?(Hash)
          valid_structure?(data[k], v)

        elsif v.nil?
          !data.has_key?(k)

        else
          data[k] == v
        end
      end
    end

    #
    # Validate data of any rule type.
    #
    # @param [Object] data the data to be validated
    # @return true if valid, false if invalid
    #
    def valid?(data)

      @data = data

      rule = @rule.is_a?(Proc) ? @rule.call(@data) : @rule

      result = if rule.kind_of?(Regexp)
        valid_pattern?(data)

      elsif rule.kind_of?(Validation)
        rule.valid?(data)

      elsif rule.kind_of?(Hash)
        valid_structure?(data)

      elsif @block
        @block.call(data)

      else
        data == @rule
      end

      @data = nil

      result

    end

  end

end
