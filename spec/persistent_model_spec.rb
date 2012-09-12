require 'spec_helper'

include PersistentModels

describe CleanModel::Persistent do

  context 'Respond to persistence methods' do

    subject { Post.new }

    it 'Class methods ' do
      Post.should respond_to :create
      Post.should respond_to :create!
    end

    it 'Instance methods' do
      should respond_to :id
      should respond_to :id=
      should respond_to :save
      should respond_to :save!
      should respond_to :update_attributes
      should respond_to :destroy
      should respond_to :new_record?
      should respond_to :persisted?
    end

  end

  context 'Undefined persistence methods' do

    it 'Can not create' do
      expect { Post.new.send :create }.to raise_error CleanModel::UndefinedPersistenceMethod
    end

    it 'Can not update' do
      expect { Post.new.send :update }.to raise_error CleanModel::UndefinedPersistenceMethod
    end

    it 'Can not destroy' do
      expect { Post.new.send :destroy }.to raise_error CleanModel::UndefinedPersistenceMethod
    end

  end

  context 'Defined persistence methods' do

    it 'Create with class method' do
      Post.any_instance.stub(:create).and_return(:true)
      Post.any_instance.should_receive :create

      Post.create(subject: 'Title', content: 'Some text').should be_a Post
    end

    it 'Create with instance method' do
      post = Post.new subject: 'Title', content: 'Some text'

      post.stub(:create) { true }
      post.should_receive :create

      post.save.should be_true

      post.stub(:id) { rand(1000) }

      post.should be_persisted
      post.should_not be_new_record
    end

    it 'Save persisted model' do
      post = Post.new id: 1, subject: 'Title', content: 'Some text'
      post.should be_persisted
      post.should_not be_new_record

      post.stub(:update) { true }
      post.should_receive :update

      post.save.should be_true
    end

    it 'Update attributes' do
      post = Post.new id: 1, subject: 'Title', content: 'Some text'

      post.stub(:update) { true }
      post.should_receive :update

      post.update_attributes(content: 'Other text').should be_true
    end

    it 'Destroy persisted model' do
      post = Post.new id: 1, subject: 'Title', content: 'Some text'

      post.stub(:destroy) { true }
      post.should_receive :destroy

      post.destroy.should be_true
    end

  end

  context 'Active model conversion' do

    let(:post) { Post.new id: 1 }

    it 'Respond to instance methods' do
      post.to_model.should eq post
      post.to_key.should eq [1]
      post.to_param.should eq '1'
      post.to_partial_path.should eq 'persistent_models/posts/post'
    end

  end

end