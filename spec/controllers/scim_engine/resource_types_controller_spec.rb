require 'rails_helper'

describe ScimEngine::ResourceTypesController do
  routes { ScimEngine::Engine.routes }

  before(:each) { allow(controller).to receive(:authenticated?).and_return(true) }

  describe 'GET index' do
    it 'renders the resource type for user' do
      get :index, format: :scim
      response_hash = JSON.parse(response.body)
      expected_response = [ ScimEngine::Resources::User.resource_type(scim_resource_type_url(name: 'User')),
                            ScimEngine::Resources::Group.resource_type(scim_resource_type_url(name: 'Group'))
      ].to_json

      response_hash = JSON.parse(response.body)
      expect(response_hash).to eql(JSON.parse(expected_response))
    end

    it 'renders custom resource types' do
      custom_resource = Class.new(ScimEngine::Resources::Base) do
        set_schema ScimEngine::Schema::User

        def self.endpoint
          "/Gaga"
        end

        def self.resource_type_id
          'Gaga'
        end
      end

      allow(ScimEngine::Engine).to receive(:custom_resources) {[ custom_resource ]}

      get :index, params: { format: :scim }
      response_hash = JSON.parse(response.body)
      expect(response_hash.size).to eql(3)
    end
  end

  describe 'GET show' do
    it 'renders the resource type for user' do
      get :show, params: { name: 'User', format: :scim }
      response_hash = JSON.parse(response.body)
      expected_response = ScimEngine::Resources::User.resource_type(scim_resource_type_url(name: 'User')).to_json
      expect(response_hash).to eql(JSON.parse(expected_response))
    end

    it 'renders the resource type for group' do
      get :show, params: { name: 'Group', format: :scim }
      response_hash = JSON.parse(response.body)
      expected_response = ScimEngine::Resources::Group.resource_type(scim_resource_type_url(name: 'Group')).to_json
      expect(response_hash).to eql(JSON.parse(expected_response))
    end

    it 'renders custom resource type' do
      custom_resource = Class.new(ScimEngine::Resources::Base) do
        set_schema ScimEngine::Schema::User

        def self.endpoint
          "/Gaga"
        end

        def self.resource_type_id
          'Gaga'
        end
      end

      allow(ScimEngine::Engine).to receive(:custom_resources) {[ custom_resource ]}


      get :show, params: { name: 'Gaga', format: :scim }
      response_hash = JSON.parse(response.body)
      expected_response = custom_resource.resource_type(scim_resource_type_url(name: 'Gaga')).to_json
      expect(response_hash).to eql(JSON.parse(expected_response))
    end
  end
end
