module BaseModels

  class Person
    include CleanModel::Base

    attribute :first_name
    attribute :last_name

    validates_presence_of :first_name, :last_name
  end

  class Engine
    include CleanModel::Base

    attribute :power, class_name: :numeric
    attribute :cylinders, class_name: :integer
    attribute :valves, class_name: 'Integer'
  end

  class Car
    include CleanModel::Base

    attribute :brand
    attribute :model
    attribute :engine, class_name: 'BaseModels::Engine'
    attribute :comfort, transformation: lambda { |v| v.is_a?(String) ? v.split(',').map(&:strip) : v }
  end

  class Factory
    include CleanModel::Base

    attribute :cars, collection: 'BaseModels::Car'
  end

end