require 'rails_helper'

describe ScimEngine::Resources::Base do

  CustomSchema = Class.new(ScimEngine::Schema::Base) do

    def self.id
      'custom-id'
    end

    def self.scim_attributes
      [
        ScimEngine::Schema::Attribute.new(
          name: 'name', complexType: ScimEngine::ComplexTypes::Name, required: false
        ),
        ScimEngine::Schema::Attribute.new(
          name: 'names', multiValued: true, complexType: ScimEngine::ComplexTypes::Name, required: false
        )
      ]
    end
  end

  CustomResourse = Class.new(ScimEngine::Resources::Base) do
    set_schema CustomSchema
  end

  describe '#initialize' do
    it 'builds the nested type' do
      resource = CustomResourse.new(name: {
        givenName: 'John',
        familyName: 'Smith'
      })

      expect(resource.name.is_a?(ScimEngine::ComplexTypes::Name)).to be(true)
      expect(resource.name.givenName).to eql('John')
      expect(resource.name.familyName).to eql('Smith')
    end

    it 'builds an array of nested resources' do
      resource = CustomResourse.new(names: [
        {
          givenName: 'John',
          familyName: 'Smith'
        },
        {
          givenName: 'Jane',
          familyName: 'Snow'
        }
      ])

      expect(resource.names.is_a?(Array)).to be(true)
      expect(resource.names.first.is_a?(ScimEngine::ComplexTypes::Name)).to be(true)
      expect(resource.names.first.givenName).to eql('John')
      expect(resource.names.first.familyName).to eql('Smith')
      expect(resource.names.second.is_a?(ScimEngine::ComplexTypes::Name)).to be(true)
      expect(resource.names.second.givenName).to eql('Jane')
      expect(resource.names.second.familyName).to eql('Snow')
      expect(resource.valid?).to be(true)
    end

    it 'builds an array of nested resources which is invalid if the hash does not follow the schema of the complex type' do
      resource = CustomResourse.new(names: [
        {
          givenName: 'John',
          familyName: 123
        }
      ])

      expect(resource.names.is_a?(Array)).to be(true)
      expect(resource.names.first.is_a?(ScimEngine::ComplexTypes::Name)).to be(true)
      expect(resource.names.first.givenName).to eql('John')
      expect(resource.names.first.familyName).to eql(123)
      expect(resource.valid?).to be(false)
    end

  end

  describe '#as_json' do
    it 'renders the json with the resourceType' do
      resource = CustomResourse.new(name: {
        givenName: 'John',
        familyName: 'Smith'
      })

      result = resource.as_json
      expect(result['schemas']).to eql(['custom-id'])
      expect(result['meta']['resourceType']).to eql('CustomResourse')
      expect(result['errors']).to be_nil
    end
  end

  describe 'dynamic setters based on schema' do

    CustomSchema = Class.new(ScimEngine::Schema::Base) do
      def self.scim_attributes
        [
          ScimEngine::Schema::Attribute.new(name: 'customField', type: 'string', required: false),
          ScimEngine::Schema::Attribute.new(name: 'anotherCustomField', type: 'boolean', required: false),
          ScimEngine::Schema::Attribute.new(name: 'name', complexType: ScimEngine::ComplexTypes::Name, required: false)
        ]
      end
    end

    CustomNameType = Class.new(ScimEngine::ComplexTypes::Base) do
      set_schema ScimEngine::Schema::Name
    end

    it 'defines a setter for an attribute in the schema' do
      described_class.set_schema CustomSchema
      resource = described_class.new(customField: '100',
                                     anotherCustomField: true)
      expect(resource.customField).to eql('100')
      expect(resource.anotherCustomField).to eql(true)
      expect(resource.valid?).to be(true)
    end

    it 'defines a setter for an attribute in the schema' do
      described_class.set_schema CustomSchema
      resource = described_class.new(anotherCustomField: false)
      expect(resource.anotherCustomField).to eql(false)
      expect(resource.valid?).to be(true)
    end


    it 'validates that the provided attributes match their schema' do
      described_class.set_schema CustomSchema
      resource = described_class.new(
        name: ScimEngine::ComplexTypes::Name.new(
          givenName: 'John',
          familyName: 'Smith'
        ))
      expect(resource.valid?).to be(true)
    end

    it 'validates that nested types' do
      described_class.set_schema CustomSchema
      resource = described_class.new(
        name: ScimEngine::ComplexTypes::Name.new(
          givenName: 100,
          familyName: 'Smith'
        ))
      expect(resource.valid?).to be(false)
    end


    it 'allows custom complex types as long as the schema matches' do
      described_class.set_schema CustomSchema
      resource = described_class.new(
        name: CustomNameType.new(
          givenName: 'John',
          familyName: 'Smith'
        ))
      expect(resource.valid?).to be(true)
    end


    it 'doesnt accept email for a name' do
      described_class.set_schema CustomSchema
      resource = described_class.new(
        name: ScimEngine::ComplexTypes::Email.new(
          value: 'john@smith.com',
          primary: true
        ))
      expect(resource.valid?).to be(false)
    end

    it 'doesnt accept a complex type for a string' do
      described_class.set_schema CustomSchema
      resource = described_class.new(
        customField: ScimEngine::ComplexTypes::Email.new(
          value: 'john@smith.com',
          primary: true
        ))
      expect(resource.valid?).to be(false)
    end

    it 'doesnt accept a string for a boolean' do
      described_class.set_schema CustomSchema
      resource = described_class.new(anotherCustomField: 'value')
      expect(resource.valid?).to be(false)
    end

  end

  context 'schema extension' do
    customSchema = Class.new(ScimEngine::Schema::Base) do
      def self.id
        'custom-id'
      end

      def self.scim_attributes
        [ ScimEngine::Schema::Attribute.new(name: 'name', type: 'string') ]
      end
    end

    extensionSchema = Class.new(ScimEngine::Schema::Base) do
      def self.id
        'extension-id'
      end

      def self.scim_attributes
        [ ScimEngine::Schema::Attribute.new(name: 'relationship', type: 'string') ]
      end
    end

    let(:resource_class) {
      Class.new(ScimEngine::Resources::Base) do
        set_schema customSchema
        extend_schema extensionSchema


        def self.endpoint
          '/gaga'
        end
        def self.resource_type_id
          'CustomResource'
        end
      end
    }

    describe '#initialize' do
      it 'allows setting extension attributes' do
        resource = resource_class.new('extension-id' => {relationship: 'GAGA'})
        expect(resource.relationship).to eql('GAGA')
      end
    end

    describe '#as_json' do
      it 'namespaces the extension attributes' do
        resource = resource_class.new(relationship: 'GAGA')
        hash = resource.as_json
        expect(hash["schemas"]).to eql(['custom-id', 'extension-id'])
        expect(hash["extension-id"]).to eql("relationship" => 'GAGA')
      end
    end

    describe '.resource_type' do
      it 'appends the extension schemas' do
        resource_type = resource_class.resource_type('http://gaga')
        expect(resource_type.meta.location).to eql('http://gaga')
        expect(resource_type.schemaExtensions.count).to eql(1)
      end
    end

  end
end
