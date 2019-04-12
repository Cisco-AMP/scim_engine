module ScimEngine
  module ComplexTypes
    # Represents the complex email type.
    # @see ScimEngine::Schema::Email
    class Email < Base
      set_schema ScimEngine::Schema::Email

      # returns the json representation of an email.
      def as_json(options = {})
        {'type' => 'work', 'primary' => true}.merge(super(options))
      end
    end
  end
end
