module ScimEngine
  module Schema
    # Represnts the schema for the Group resource
    # @see ScimEngine::Resources::Group
    class Group < Base

      def initialize(options = {})
        super(name: 'Group',
              id: self.class.id,
              description: 'Represents a Group',
              scim_attributes: self.class.scim_attributes)
      end

      def self.id
        'urn:ietf:params:scim:schemas:core:2.0:Group'
      end

      def self.scim_attributes
        [
          Attribute.new(name: 'displayName', type: 'string'),
          Attribute.new(name: 'members', multiValued: true, complexType: ScimEngine::ComplexTypes::Reference, mutability: 'readOnly', required: false)
        ]
      end

    end
  end
end
