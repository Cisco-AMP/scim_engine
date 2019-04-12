require 'rails_helper'

describe ScimEngine::ApplicationController do

  context 'custom authentication' do
    before do
      allow(ScimEngine::Engine).to receive(:username) { 'A' }
      allow(ScimEngine::Engine).to receive(:password) { 'B' }
    end

    controller do
      rescue_from StandardError, with: :handle_resource_not_found

      def index
        render json: { 'message' => 'cool, cool!' }, format: :scim
      end
    end

    it 'renders success when valid creds are given' do
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('A', 'B')

      get :index, params: { format: :scim }
      expect(response).to be_ok
      expect(JSON.parse(response.body)).to eql({ 'message' => 'cool, cool!' })
    end

    it 'renders failure with bad password' do
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('A', 'C')

      get :index, params: { format: :scim }
      expect(response).not_to be_ok
    end

    it 'renders failure with bad user name' do
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('C', 'B')

      get :index, params: { format: :scim }
      expect(response).not_to be_ok
    end


    it 'renders failure with bad user name and password' do
      request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials('C', 'D')

      get :index, params: { format: :scim }
      expect(response).not_to be_ok
    end



  end


  context 'authenticated' do
    controller do
      rescue_from StandardError, with: :handle_resource_not_found

      def index
        render json: { 'message' => 'cool, cool!' }, format: :scim
      end

      def authenticated?
        true
      end
    end

    describe 'authenticate' do
      it 'renders index if authenticated' do
        get :index, params: { format: :scim }
        expect(response).to be_ok
        expect(JSON.parse(response.body)).to eql({ 'message' => 'cool, cool!' })
      end

      it 'renders not authorized response if not authenticated' do
        allow(controller).to receive(:authenticated?) { false }
        get :index, params: { format: :scim }
        expect(response).to have_http_status(:unauthorized)
        parsed_body = JSON.parse(response.body)
        expect(parsed_body).to include('schemas' => ['urn:ietf:params:scim:api:messages:2.0:Error'])
        expect(parsed_body).to include('detail' => 'Requires authentication')
        expect(parsed_body).to include('status' => '401')
      end

      it 'renders resource not found response when resource cannot be found for the given id' do
        allow(controller).to receive(:index).and_raise(StandardError)
        get :index, params: { id: 10, format: :scim }
        expect(response).to have_http_status(:not_found)
        parsed_body = JSON.parse(response.body)
        expect(parsed_body).to include('schemas' => ['urn:ietf:params:scim:api:messages:2.0:Error'])
        expect(parsed_body).to include('detail' => 'Resource 10 not found')
        expect(parsed_body).to include('status' => '404')
      end
    end

    describe 'require_scim' do
      it 'renders not acceptable if the request does not use scim type' do
        get :index
        expect(response).to have_http_status(:not_acceptable)

        expect(JSON.parse(response.body)['detail']).to eql('Only application/scim+json type is accepted.')
      end
    end
  end
end
