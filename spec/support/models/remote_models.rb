module RemoteModels

  class User
    include CleanModel::Remote

    connection host: 'localhost', port: 9999

    attribute :first_name
    attribute :last_name
    attribute :email
  end

end