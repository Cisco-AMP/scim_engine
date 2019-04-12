module ScimEngine
  module ComplexTypes
    class Base
      include ActiveModel::Model
      include ScimEngine::Schema::DerivedAttributes
      include ScimEngine::Errors

      def initialize(options={})
        super
        @errors = ActiveModel::Errors.new(self)
      end

      def as_json(options={})
        options[:except] ||= ['errors']
        super.except(options)
      end
    end
  end
end
