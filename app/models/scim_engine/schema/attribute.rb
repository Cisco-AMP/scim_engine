module ScimEngine
  module Schema
    class Attribute
      include ActiveModel::Model
      include ScimEngine::Errors
      attr_accessor :name, :type, :multiValued, :required, :caseExact, :mutability, :returned, :uniqueness, :subAttributes, :complexType, :canonicalValues

      def initialize(options = {})
        defaults = {
          multiValued: false,
          required: true,
          caseExact: false,
          mutability: 'readWrite',
          uniqueness: 'none',
          returned: 'default',
          canonicalValues: []
        }

        if options[:complexType]
          defaults.merge!(type: 'complex', subAttributes: options[:complexType].schema.scim_attributes)
        end

        super(defaults.merge(options || {}))
      end

      def valid?(value)
        return valid_blank? if value.blank? && !value.is_a?(FalseClass)

        if type == 'complex'
          return all_valid?(complexType, value) if multiValued
          valid_complex_type?(value)
        else
          valid_simple_type?(value)
        end
      end

      def valid_blank?
        return true unless self.required
        errors.add(self.name, "is required")
        false
      end

      def valid_complex_type?(value)
        if !value.class.respond_to?(:schema) || value.class.schema != complexType.schema
          errors.add(self.name, "has to follow the complexType format.")
          return false
        end
        value.class.schema.valid?(value)
        return true if value.errors.empty?
        add_errors_from_hash(value.errors.to_hash, prefix: self.name)
        false
      end

      def valid_simple_type?(value)
        valid = (type == 'string' && value.is_a?(String)) ||
          (type == 'boolean' && (value.is_a?(TrueClass) || value.is_a?(FalseClass))) ||
          (type == 'integer' && (value.is_a?(Integer))) ||
          (type == 'dateTime' && valid_date_time?(value))
        errors.add(self.name, "has the wrong type. It has to be a(n) #{self.type}.") unless valid
        valid
      end

      def valid_date_time?(value)
        !!Time.iso8601(value)
      rescue ArgumentError
        false
      end

      def all_valid?(complex_type, value)
        validations = value.map {|value_in_array| valid_complex_type?(value_in_array)}
        validations.all?
      end

      def as_json(options = {})
        options[:except] ||= ['complexType']
        options[:except] << 'canonicalValues' if canonicalValues.empty?
        super.except(options)
      end

    end
  end
end
