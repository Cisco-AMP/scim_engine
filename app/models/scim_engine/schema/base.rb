module ScimEngine
  module Schema
    class Base
      include ActiveModel::Model
      attr_accessor :id, :name, :description, :scim_attributes, :meta

      def initialize(options = {})
        super
        @meta = Meta.new(resourceType: "Schema")
      end

      def as_json(options = {})
        @meta.location = ScimEngine::Engine.routes.url_helpers.scim_schemas_path(name: id)
        original = super
        original.merge('attributes' => original.delete('scim_attributes'))
      end

      def self.valid?(resource)
        cloned_scim_attributes.each do |scim_attribute|
          resource.add_errors_from_hash(scim_attribute.errors.to_hash) unless scim_attribute.valid?(resource.send(scim_attribute.name))
        end
      end

      def self.cloned_scim_attributes
        scim_attributes.map { |scim_attribute| scim_attribute.clone }
      end

    end
  end
end
