require 'json'

module DeeplyValid

  # 
  # The ValidationHelpers module provides a number of 'macros'
  # for creating Validations
  #

  module ValidationHelpers

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      #
      # Validates tokens, ie. strings with letters, numbers, and underscores
      #
      # @param [Integer, Range] size Optional size limitation
      # @return [Validation] The validation
      #
      def token(size = nil)
        Validation.new { |d| (d =~ /^[0-9a-zA-Z_]*$/) && in_range?(d.size, size) }
      end

      #
      # Validates strings by size
      #
      # @param [Integer, Range] size Optional size limitation
      # @return [Validation] The validation
      #
      def string(size = nil)
        Validation.new { |d| d.is_a?(String) && in_range?(d.size, size) }
      end

      #
      # Validates integer with optional limit
      #
      # @param [Integer, Range] limit 
      # @return [Validation] The validation
      #
      def integer(limit = nil)
        Validation.new { |d| d.is_a?(Integer) && in_range?(d, limit) }
      end

      #
      # Validates date with optional limit
      #
      # @param limit 
      # @return [Validation] The validation
      #
      def date(limit = nil)
        Validation.new { |d| d.is_a?(Date) && in_range?(d, limit) }
      end

      #
      # Validates float with optional limit
      #
      # @param limit 
      # @return [Validation] The validation
      #
      def float(limit = nil)
        Validation.new { |d| d.is_a?(Float) && in_range?(d, limit) }
      end

      #
      # Validates datetime with optional limit
      #
      # @param [Integer, Range] limit 
      # @return [Validation] The validation
      #
      def datetime(limit = nil)
        Validation.new { |d| d.is_a?(DateTime) && in_range?(d, limit) }
      end

      #
      # Validates time with optional limit
      #
      # @param [Integer, Range] limit 
      # @return [Validation] The validation
      #
      def time(limit = nil)
        Validation.new { |d| d.is_a?(Time) && in_range?(d, limit) }
      end

      #
      # Validate by class
      #
      # @param [Class] klass The class
      # @return [Validation] The validation
      #
      def instance_of(klass)
        Validation.new { |d| d.kind_of?(klass) }
      end

      #
      # Validate that a string is valid JSON
      #
      # @return [Validation] The validation
      #
      def json(size=nil)
        Validation.new do |d| 
          begin
            JSON.parse(d)
          rescue
            false
          else
            in_range?(d.size, size)
          end
        end
      end

      #
      # Check that any of the specified Validations are met
      # 
      # @param [Validation] options One or more Validation instances
      # @return [Validation] The validation
      #
      def any(*options)
        if options.all? { |v| v.is_a?(Validation) }
          Validation.new do |d| 
            options.any? { |v| v.valid?(d) }
          end
        else
          Validation.new do |d| 
            options.include?(d)
          end
        end
      end

      #
      # Check that all of the specified Validations are met
      # 
      # @param [Validation] options One or more Validation instances
      # @return [Validation] The validation
      #
      def all(*options)
        Validation.new do |d| 
          options.all? { |v| v.valid?(d) }
        end
      end

      #
      # Validate true or false
      # 
      # @return [Validation] The validation
      #
      def boolean
        any(true, false)
      end

      #
      # Validate all keys / values in a hash
      #
      # == Example
      #
      # To make sure that all keys are 32 char long tokens,
      # and all values have a size from 1 to 128 chars, 
      # do this:
      #
      #   hash( token(32) => string(1..128) )
      # 
      # @param [Hash] example The desired hash format
      # @return [Validation] The validation
      #
      def hash(example = nil)
        return instance_of(Hash) unless example

        k_rule, v_rule = example.to_a.first

        k_validation = k_rule.is_a?(Validation) ? k_rule : Validation.new(k_rule)
        v_validation = v_rule.is_a?(Validation) ? v_rule : Validation.new(v_rule)

        Validation.new do |d| 
          d.is_a?(Hash) && d.all? { |k, v| k_validation.valid?(k) && v_validation.valid?(v) }
        end
      end

      #
      # Validate all values in an array
      #
      # @param [Validation] rule The validation rule
      # @return [Validation] The validation
      #
      def array(rule = nil)
        return instance_of(Array) unless rule

        validation = rule.is_a?(Validation) ? rule : Validation.new(rule)

        Validation.new do |d| 
          d.is_a?(Array) && d.all? { |v| validation.valid?(v) }
        end
      end

      #
      # Determine if a val is included in a range. A number of
      # range formats are supportet
      #
      # == Example:
      #
      # All these will return true
      #
      #   in_range(1, 1)    
      #   in_range(1, 0..9)    
      #   in_range(1, :min => 0, :max => 9)    
      #   in_range(1, :less_than_or_equal_to => 2)    
      #
      # @param val A number, date, or other other object to compare
      # @param [Integer, Range, Hash] range The range to test `val` against
      #
      def in_range?(val, range)
        return true unless range

        if range.is_a?(Hash)
          result = true
          result &= ( val < range[:before] ) if range[:before]
          result &= ( val > range[:after] ) if range[:after]
          result &= ( val <= range[:max] ) if range[:max]
          result &= ( val >= range[:min] ) if range[:min]
          result &= ( val < range[:less_than] ) if range[:less_than]
          result &= ( val <= range[:less_than_or_equal_to] ) if range[:less_than_or_equal_to]
          result &= ( val > range[:greater_than] ) if range[:greater_than]
          result &= ( val >= range[:greater_than_or_equal_to] ) if range[:greater_than_or_equal_to]
          result
        else
          range = [range] unless range.respond_to?(:include?)
          range.include?(val)
        end

        end
    end
  end
end
