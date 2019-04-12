Rails.application.routes.draw do

  mount ScimEngine::Engine => "/scim_engine"
end
