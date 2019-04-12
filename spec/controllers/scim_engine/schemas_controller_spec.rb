require 'rails_helper'

describe ScimEngine::SchemasController do

  before(:each) { allow(controller).to receive(:authenticated?).and_return(true) }

  controller do
    def index
      super
    end
  end
  describe '#index' do
    it 'returns a collection of supported schemas' do
      get :index, params: { format: :scim }
      expect(response).to be_ok
      parsed_body = JSON.parse(response.body)
      expect(parsed_body.length).to eql(2)
      schema_names = parsed_body.map {|schema| schema['name']}
      expect(schema_names).to match_array(['User', 'Group'])
    end

    it 'returns only the User schema when its id is provided' do
      get :index, params: { name: ScimEngine::Schema::User.id, format: :scim }
      expect(response).to be_ok
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['name']).to eql('User')
    end

    it 'returns only the Group schema when its id is provided' do
      get :index, params: { name: ScimEngine::Schema::Group.id, format: :scim }
      expect(response).to be_ok
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['name']).to eql('Group')
    end

    it 'returns only the License schemas when its id is provided' do
      license_schema = Class.new(ScimEngine::Schema::Base) do
        def initialize(options = {})
        super(name: 'License',
              id: self.class.id,
              description: 'Represents a License')
        end
        def self.id
          'License'
        end
        def self.scim_attributes
          []
        end
      end

      license_resource = Class.new(ScimEngine::Resources::Base) do
        set_schema license_schema
        def self.endopint
          '/Gaga'
        end
      end

      allow(ScimEngine::Engine).to receive(:custom_resources) {[license_resource]}
      get :index, params: { name: license_schema.id, format: :scim }
      expect(response).to be_ok
      parsed_body = JSON.parse(response.body)
      expect(parsed_body['name']).to eql('License')
    end
  end
end

