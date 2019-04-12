module ScimEngine
  module ComplexTypes
    class Email < Base
      set_schema ScimEngine::Schema::Email

      def as_json(options = {})
        {'type' => 'work', 'primary' => true}.merge(super(options))
      end
    end
  end
end
