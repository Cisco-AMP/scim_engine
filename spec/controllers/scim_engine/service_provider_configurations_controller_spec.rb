require 'rails_helper'

describe ScimEngine::ServiceProviderConfigurationsController do

  before(:each) { allow(controller).to receive(:authenticated?).and_return(true) }

  controller do
    def show
      super
    end
  end
  describe '#show' do
    it 'renders the servive provider configurations' do
      get :show, params: { id: 'fake', format: :scim }

      expect(response).to be_ok
      expect(JSON.parse(response.body)).to include('patch' => {'supported' => false})
    end
  end

end
