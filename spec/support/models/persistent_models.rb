module PersistentModels

  class Post
    include CleanModel::Persistent

    attribute :subject
    attribute :content
  end

end