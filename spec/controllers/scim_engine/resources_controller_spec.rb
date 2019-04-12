require 'rails_helper'

describe ScimEngine::ResourcesController do

  before(:each) { allow(controller).to receive(:authenticated?).and_return(true) }

  controller do
    def show
      super do |id|
        ScimEngine::Resources::Group.new(id: id)
      end
    end

    def create
      super(ScimEngine::Resources::Group) do |resource|
        resource
      end
    end

    def update
      super(ScimEngine::Resources::Group) do |resource|
        resource
      end
    end

    def destroy
      super do |id|
        successful_delete?
      end
    end

    def successful_delete?
      true
    end
  end

  describe 'GET show' do
    it 'renders the resource' do
      get :show, params: { id: '10', format: :scim }

      expect(response).to be_ok
      expect(JSON.parse(response.body)).to include('id' => '10')
    end
  end

  describe 'POST create' do
    it 'returns error if body is missing' do
      post :create, params: { format: :scim }
      expect(response.status).to eql(400)
      expect(JSON.parse(response.body)['detail']).to eql('must provide a request body')
    end

    it 'works if the request is valid' do
      post :create, params: { displayName: 'Sauron biz', format: :scim }
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['displayName']).to eql('Sauron biz')
    end

    it 'renders error if resource object cannot be built from the params' do
      put :update, params: { id: 'group-id', name: {email: 'a@b.com'}, format: :scim }
      expect(response.status).to eql(400)
      expect(JSON.parse(response.body)['detail']).to match(/^Invalid/)
    end

    it 'renders application side error' do
      allow_any_instance_of(ScimEngine::Resources::Group).to receive(:to_json).and_raise(ScimEngine::ErrorResponse.new(status: 400, detail: 'gaga'))
      put :update, params: { id: 'group-id', displayName: 'invalid name', format: :scim }
      expect(response.status).to eql(400)
      expect(JSON.parse(response.body)['detail']).to eql('gaga')
    end

    it 'renders error if id is provided' do
      post :create, params: { id: 'some-id', displayName: 'sauron', format: :scim }

      expect(response).to have_http_status(:bad_request)

      parsed_response = JSON.parse(response.body)
      expect(parsed_response['detail']).to start_with('id and externalId are not valid parameters for create')
    end

    it 'renders error if externalId is provided' do
      post :create, params: { externalId: 'some-id', displayName: 'sauron', format: :scim }

      expect(response).to have_http_status(:bad_request)

      parsed_response = JSON.parse(response.body)
      expect(parsed_response['detail']).to start_with('id and externalId are not valid parameters for create')
    end
  end

  describe 'PUT update' do
    it 'returns error if body is missing' do
      put :update, params: { id: 'group-id', format: :scim }
      expect(response.status).to eql(400)
      expect(JSON.parse(response.body)['detail']).to eql('must provide a request body')
    end

    it 'works if the request is valid' do
      put :update, params: { id: 'group-id', displayName: 'sauron', format: :scim }
      expect(response.status).to eql(200)
      expect(JSON.parse(response.body)['displayName']).to eql('sauron')
    end

    it 'renders error if resource object cannot be built from the params' do
      put :update, params: { id: 'group-id', name: {email: 'a@b.com'}, format: :scim }
      expect(response.status).to eql(400)
      expect(JSON.parse(response.body)['detail']).to match(/^Invalid/)
    end

    it 'renders application side error' do
      allow_any_instance_of(ScimEngine::Resources::Group).to receive(:to_json).and_raise(ScimEngine::ErrorResponse.new(status: 400, detail: 'gaga'))
      put :update, params: { id: 'group-id', displayName: 'invalid name', format: :scim }
      expect(response.status).to eql(400)
      expect(JSON.parse(response.body)['detail']).to eql('gaga')
    end

  end

  describe 'DELETE destroy' do
    it 'returns an empty response with no content status if deletion is successful' do
      delete :destroy, params: { id: 'group-id', format: :scim }
      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
    end

    it 'renders error if deletion fails' do
      allow(controller).to receive(:successful_delete?).and_return(false)
      delete :destroy, params: { id: 'group-id', format: :scim }
      expect(response).to have_http_status(:internal_server_error)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['detail']).to eql("Failed to delete the resource with id 'group-id'. Please try again later")
    end
  end
end
