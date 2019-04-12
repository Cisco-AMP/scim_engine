require 'rails_helper'

describe ScimEngine::Resources::User do
  describe '#name' do
    it 'allows a setter for a valid name' do
      user = described_class.new(name: ScimEngine::ComplexTypes::Name.new(
        familyName: 'Smith',
        givenName: 'John',
        formatted: 'John Smith'
      ))

      expect(user.name.familyName).to eql('Smith')
      expect(user.name.givenName).to eql('John')
      expect(user.name.formatted).to eql('John Smith')
      expect(user.as_json['name']['errors']).to be_nil
    end

    it 'validates that the provided name matches the name schema' do
      user = described_class.new(name: ScimEngine::ComplexTypes::Email.new(
        value: 'john@smoth.com',
        primary: true
      ))

      expect(user.valid?).to be(false)
    end
  end

  describe '#add_errors_from_hash' do
    let(:user) { described_class.new }

    it 'adds the error when the value is a string' do
      user.add_errors_from_hash(key: 'some error')
      expect(user.errors.messages).to eql({key: ['some error']})
      expect(user.errors.full_messages).to eql(['Key some error'])
    end

    it 'adds the error when the value is an array' do
      user.add_errors_from_hash(key: ['error1', 'error2'])
      expect(user.errors.messages).to eql({key: ['error1', 'error2']})
      expect(user.errors.full_messages).to eql(['Key error1', 'Key error2'])
    end

    it 'adds the error with prefix when the value is a string' do
      user.add_errors_from_hash({key: 'some error'}, prefix: :pre)
      expect(user.errors.messages).to eql({:'pre.key' => ['some error']})
      expect(user.errors.full_messages).to eql(['Pre key some error'])
    end

    it 'adds the error wity prefix when the value is an array' do
      user.add_errors_from_hash({key: ['error1', 'error2']}, prefix: :pre)
      expect(user.errors.messages).to eql({:'pre.key' => ['error1', 'error2']})
      expect(user.errors.full_messages).to eql(['Pre key error1', 'Pre key error2'])
    end
  end
end
