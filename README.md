# ScimEngine

[![Build Status](https://travis-ci.org/Cisco-AMP/scim_engine.svg?branch=master)](https://travis-ci.org/Cisco-AMP/scim_engine)

## Why ScimEngine Exists?

There's no general purpose SCIM SDK for Ruby on Rails. As a result,
anyone implementing SCIM will need to take care of the SCIM schema and
protocol, which may take a significant overhead compared the
implementation of the actual APIs. This project aims to extract SCIM
specifics as a rails engine that can be plugged into a Ruby on Rails
project.

## How to Use?

In your Gemfile, add:

`gem 'scim_engine'`

Mount this engine in config/routes:

```ruby
namespace :scim do
  mount ScimEngine::Engine => '/'
end
```
This will provide you with routes for ServerProviderConfig, Schemas,
and ResourceTypes under `/scim` prefix.

You can decide which SCIM resources you want to support, and provide
routes / controllers accordingly. For example, to support the `User`
resource type, add the following to your routes:

```ruby
namespace :scim do
  get 'Users/:id', to: 'users#show', as: :user
  post 'Users', to: 'users#create'
  put 'Users/:id', to: 'users#update'
  delete 'Users/:id', to: 'users#destroy'
  mount ScimEngine::Engine => '/'
end
```

Add your controller:

```ruby
# app/controllers/scim/users_controller.rb

module Scim

  # ScimEngine::ResourcesController uses a template method so that the
  # subclasses can provide the fillers with minimal effort solely focused on
  # application code leaving the SCIM protocol and schema specific code within the
  # engine.

  class UsersController < ScimEngine::ResourcesController

    def show
      super do |user_id|
        user = find_user(user_id)
        user.to_scim(location: url_for(action: :show, id: user_id))
      end
    end

    def create
      super(resource_type, &method(:save))
    end

    def update
      super(resource_type, &method(:save))
    end

    def destroy
      super do |user_id|
        user = find_user(user_id)
        user.delete
      end
    end


    protected

    def save(scim_user, is_create: false)
      #convert the ScimEngine::Resources::User to your application object
      #and save
    rescue ActiveRecord::RecordInvalid => exception
      # Map the enternal errors to a ScimEngine error
      raise ScimEngine::ResourceInvalidError.new()
    end

    # tell the base controller which resource you're handling
    def resource_type
      ScimEngine::Resources::User
    end

    def find_user(user_id)
      # find your user
    end

  end
end

```

To support custom `Resource` types, simply add a controller and provide
the custom resource type via the `resource_type` method.
