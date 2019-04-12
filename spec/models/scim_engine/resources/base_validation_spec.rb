require 'rails_helper'

describe ScimEngine::Resources::Base do

  describe '#valid?' do
    MyCustomSchema = Class.new(ScimEngine::Schema::Base) do
      def self.id
        'custom-id'
      end

      def self.scim_attributes
        [
          ScimEngine::Schema::Attribute.new(
            name: 'userName', type: 'string', required: false
          ),
          ScimEngine::Schema::Attribute.new(
            name: 'enforce', type: 'boolean', required: true
          ),
          ScimEngine::Schema::Attribute.new(
            name: 'complexName', complexType: ScimEngine::ComplexTypes::Name, required: false
          ),
          ScimEngine::Schema::Attribute.new(
            name: 'complexNames', complexType: ScimEngine::ComplexTypes::Name, multiValued:true, required: false
          )
        ]
      end
    end

    MyCustomResource =  Class.new(ScimEngine::Resources::Base) do
      set_schema MyCustomSchema
    end

    it 'adds validation errors to the resource for simple attributes' do
      resource = MyCustomResource.new(userName: 10)
      expect(resource.valid?).to be(false)
      expect(resource.errors.full_messages).to match_array(['Username has the wrong type. It has to be a(n) string.', 'Enforce is required'])
    end

    it 'adds validation errors to the resource for the complex attribute when the value does not match the schema' do
      resource = MyCustomResource.new(complexName: 10, enforce: false)
      expect(resource.valid?).to be(false)
      expect(resource.errors.full_messages).to match_array(['Complexname has to follow the complexType format.'])
    end

    it 'adds validation errors to the resource from what the complex type schema returns' do
      resource = MyCustomResource.new(complexName: { givenName: 10 }, enforce: false)
      expect(resource.valid?).to be(false)
      expect(resource.errors.full_messages).to match_array(["Complexname familyname is required", "Complexname givenname has the wrong type. It has to be a(n) string."])
    end

    it 'adds validation errors to the resource from what the complex type schema returns when it is multi-valued' do
      resource = MyCustomResource.new(complexNames: [
        "Jane Austen",
        { givenName: 'Jane', familyName: true }
      ],
      enforce: false)
      expect(resource.valid?).to be(false)
      expect(resource.errors.full_messages).to match_array(["Complexnames has to follow the complexType format.", "Complexnames familyname has the wrong type. It has to be a(n) string."])
    end
  end
end
