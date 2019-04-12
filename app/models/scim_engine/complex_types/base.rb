module ScimEngine
  module ComplexTypes
    # This class represents complex types that could be used inside SCIM resources.
    # Each complex type must inherit from this class. They also need to have their own schema defined.
    # @example
    #  module ScimEngine
    #    module ComplexTypes
    #      class Email < Base
    #        set_schema ScimEngine::Schema::Email
    #
    #        def as_json(options = {})
    #          {'type' => 'work', 'primary' => true}.merge(super(options))
    #        end
    #      end
    #    end
    #  end
    #
    class Base
      include ActiveModel::Model
      include ScimEngine::Schema::DerivedAttributes
      include ScimEngine::Errors

      def initialize(options={})
        super
        @errors = ActiveModel::Errors.new(self)
      end

      # Converts the object to its SCIM representation which is always a json representation
      # @param options [Hash] a hash that could provide default values for some of the attributes of this complex type object
      #
      def as_json(options={})
        options[:except] ||= ['errors']
        super.except(options)
      end
    end
  end
end
