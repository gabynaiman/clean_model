require 'spec_helper'

include RemoteModels

describe CleanModel::Persistent do

  context 'Successful operations' do

    it 'Create' do
      user = User.new first_name: 'John', last_name: 'Doe', email: 'john.doe@mail.com'

      user.stub(:create) { user.http.post('/users/create.json', user.wrapped_attributes) }
      user.should_receive :create

      stub_request(:post, 'http://localhost:9999/users/create.json').
          with(body: {user: {first_name: 'John', last_name: 'Doe', email: 'john.doe@mail.com'}}).
          to_return(body: {id: 1}.to_json)

      user.save.should be_true
      user.should be_persisted
    end

    it 'Update' do
      user = User.new id: 1, first_name: 'John', last_name: 'Doe', email: 'john.doe@mail.com'

      user.stub(:update) { user.http.put("/users/#{user.id}.json", user.wrapped_attributes(except: :id)) }
      user.should_receive :update

      stub_request(:put, 'http://localhost:9999/users/1.json').
          with(body: {user: {first_name: 'Jorge', last_name: 'Doe', email: 'john.doe@mail.com'}})

      user.update_attributes(first_name: 'Jorge').should be_true
      user.first_name.should eq 'Jorge'
    end

    it 'Destroy' do
      user = User.new id: 1, first_name: 'John', last_name: 'Doe', email: 'john.doe@mail.com'

      user.stub(:delete) { user.http.delete("/users/#{user.id}.json") }
      user.should_receive :delete

      stub_request(:delete, 'http://localhost:9999/users/1.json')

      user.destroy.should be_true
    end

  end

  context 'Failed operations' do

    it 'Save validation errors' do
      user = User.new first_name: 'John', last_name: 'Doe'

      user.stub(:create) { user.http.post('/users/create.json', user.wrapped_attributes) }

      stub_request(:post, 'http://localhost:9999/users/create.json').
          to_return(status: 422, body: {email: ["can't be blank"]}.to_json)

      user.save.should_not be_true
      user.errors[:email].should have(1).items
    end

    it 'Save with unexpected error' do
      user = User.new first_name: 'John', last_name: 'Doe', email: 'john.doe@mail.com'

      user.stub(:create) { user.http.post('/users/create.json', user.wrapped_attributes) }

      stub_request(:post, 'http://localhost:9999/users/create.json').
          to_return(status: 500, body: 'Internal Server Error')

      user.save.should_not be_true
      user.errors[:base].should have(1).items
    end

    it 'Save with timeout error' do
      user = User.new first_name: 'John', last_name: 'Doe', email: 'john.doe@mail.com'

      user.stub(:create) { user.http.post('/users/create.json', user.wrapped_attributes) }

      stub_request(:post, 'http://localhost:9999/users/create.json').to_timeout

      user.save.should_not be_true
      user.errors[:base].should have(1).items
    end

    it 'Destroy with unexpected error' do
      user = User.new id: 1, first_name: 'John', last_name: 'Doe', email: 'john.doe@mail.com'

      user.stub(:delete) { user.http.delete("/users/#{user.id}.json") }

      stub_request(:delete, 'http://localhost:9999/users/1.json').
          to_return(status: 500, body: 'Internal Server Error')

      user.destroy.should_not be_true
      user.errors[:base].should have(1).items
    end

    it 'Destroy with timeout error' do
      user = User.new id: 1, first_name: 'John', last_name: 'Doe', email: 'john.doe@mail.com'

      user.stub(:delete) { user.http.delete("/users/#{user.id}.json") }

      stub_request(:delete, 'http://localhost:9999/users/1.json').to_timeout

      user.destroy.should_not be_true
      user.errors[:base].should have(1).items
    end

  end

  context 'Http get safe' do

    before :each do
      User.stub(:find) do
        User.http_get '/users/1.json' do |response|
          User.new JSON.parse(response.body)
        end
      end
    end

    it 'Successful' do
      stub_request(:get, 'http://localhost:9999/users/1.json').
          to_return(body: {id: 1, first_name: 'John', last_name: 'Doe', email: 'john.doe@mail.com'}.to_json)

      user = User.find(1)

      user.id.should eq 1
      user.first_name.should eq 'John'
      user.last_name.should eq 'Doe'
      user.email.should eq 'john.doe@mail.com'
    end

    it 'Invalid response' do
      stub_request(:get, 'http://localhost:9999/users/1.json').
          to_return(status: 500, body: 'Internal Server Error')

      expect{User.find(1)}.to raise_error CleanModel::InvalidResponse
    end

    it 'Connection fail' do
      stub_request(:get, 'http://localhost:9999/users/1.json').to_timeout

      expect{User.find(1)}.to raise_error CleanModel::ConnectionFail
    end

  end

end