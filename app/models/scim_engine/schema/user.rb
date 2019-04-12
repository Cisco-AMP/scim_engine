module ScimEngine
  module Schema
    class User < Base

      def initialize(options = {})
        super(name: 'User',
              id: self.class.id,
              description: 'Represents a User',
              scim_attributes: self.class.scim_attributes)

      end

      def self.id
        'urn:ietf:params:scim:schemas:core:2.0:User'
      end

      def self.scim_attributes
        [
          Attribute.new(name: 'userName', type: 'string', uniqueness: 'server'),
          Attribute.new(name: 'name', complexType: ScimEngine::ComplexTypes::Name),
          Attribute.new(name: 'emails', multiValued: true, complexType: ScimEngine::ComplexTypes::Email),
          Attribute.new(name: 'groups', multiValued: true, mutability: 'immutable', complexType: ScimEngine::ComplexTypes::Reference)
        ]
      end

    end
  end
end
