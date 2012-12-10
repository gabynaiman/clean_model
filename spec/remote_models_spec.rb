require 'spec_helper'

include RemoteModels

describe CleanModel::Remote do

  context 'Successful operations' do

    it 'Create' do
      user = User.new first_name: 'John', last_name: 'Doe', email: 'john.doe@mail.com'

      user.stub(:create) { User.connection.post('/users/create.json', body: user.send(:wrapped_attributes)) }
      user.should_receive :create

      stub_request(:post, 'http://localhost:9999/users/create.json').
          with(body: {user: {first_name: 'John', last_name: 'Doe', email: 'john.doe@mail.com'}}).
          to_return(body: {id: 1}.to_json)

      user.save.should be_true
      user.should be_persisted
    end

    it 'Update' do
      user = User.new id: 1, first_name: 'John', last_name: 'Doe', email: 'john.doe@mail.com'

      user.stub(:update) { User.connection.put("/users/#{user.id}.json", body: user.send(:wrapped_attributes, except: :id)) }
      user.should_receive :update

      stub_request(:put, 'http://localhost:9999/users/1.json').
          with(body: {user: {first_name: 'Jorge', last_name: 'Doe', email: 'john.doe@mail.com'}})

      user.update_attributes(first_name: 'Jorge').should be_true
      user.first_name.should eq 'Jorge'
    end

    it 'Destroy' do
      user = User.new id: 1, first_name: 'John', last_name: 'Doe', email: 'john.doe@mail.com'

      user.stub(:delete) { User.connection.delete("/users/#{user.id}.json") }
      user.should_receive :delete

      stub_request(:delete, 'http://localhost:9999/users/1.json')

      user.destroy.should be_true
    end

  end

  context 'Failed operations' do

    it 'Save validation errors' do
      user = User.new first_name: 'John', last_name: 'Doe'

      user.stub(:create) { User.connection.post!('/users/create.json', user.send(:wrapped_attributes)) }

      stub_request(:post, 'http://localhost:9999/users/create.json').
          to_return(status: 422, body: {email: ["can't be blank"]}.to_json)

      user.save.should_not be_true
      user.errors[:email].should have(1).items
    end

    it 'Save with unexpected error' do
      user = User.new first_name: 'John', last_name: 'Doe', email: 'john.doe@mail.com'

      user.stub(:create) { User.connection.post!('/users/create.json', body: user.send(:wrapped_attributes)) }

      stub_request(:post, 'http://localhost:9999/users/create.json').
          to_return(status: 500, body: 'Internal Server Error')

      user.save.should_not be_true
      user.errors[:base].should have(1).items
    end

    it 'Save with timeout error' do
      user = User.new first_name: 'John', last_name: 'Doe', email: 'john.doe@mail.com'

      user.stub(:create) { User.connection.post!('/users/create.json', body: user.send(:wrapped_attributes)) }

      stub_request(:post, 'http://localhost:9999/users/create.json').to_timeout

      user.save.should_not be_true
      user.errors[:base].should have(1).items
    end

    it 'Destroy with unexpected error' do
      user = User.new id: 1, first_name: 'John', last_name: 'Doe', email: 'john.doe@mail.com'

      user.stub(:delete) { User.connection.delete!("/users/#{user.id}.json") }

      stub_request(:delete, 'http://localhost:9999/users/1.json').
          to_return(status: 500, body: 'Internal Server Error')

      user.destroy.should_not be_true
      user.errors[:base].should have(1).items
    end

    it 'Destroy with timeout error' do
      user = User.new id: 1, first_name: 'John', last_name: 'Doe', email: 'john.doe@mail.com'

      user.stub(:delete) { User.connection.delete!("/users/#{user.id}.json") }

      stub_request(:delete, 'http://localhost:9999/users/1.json').to_timeout

      user.destroy.should_not be_true
      user.errors[:base].should have(1).items
    end

  end

  context 'Safe requests' do

    before :each do
      User.stub(:find) do
        User.connection.get '/users/1.json' do |response|
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

      User.find(1).should be_nil
    end

    it 'Connection fail' do
      stub_request(:get, 'http://localhost:9999/users/1.json').to_timeout

      User.find(1).should be_nil
    end

  end

end