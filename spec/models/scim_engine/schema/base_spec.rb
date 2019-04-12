require 'rails_helper'

describe ScimEngine::Schema::Base do
  describe '#as_json' do
    it 'converts the scim_attributes to attributes' do
      attribute = ScimEngine::Schema::Attribute.new(name: 'nickName')
      schema = described_class.new(scim_attributes: [attribute])
      expect(schema.as_json['attributes']).to eql([attribute.as_json])
      expect(schema.as_json['scim_attributes']).to be_nil
    end
  end

  describe '#initialize' do
    it 'creates a meta' do
      schema = described_class.new
      expect(schema.meta.resourceType).to eql('Schema')
    end
  end
end
