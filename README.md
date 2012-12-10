# CleanModel

Extensions for ActiveModel to implement multiple types of models

## Installation

Add this line to your application's Gemfile:

    gem 'clean_model'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install clean_model

## Basic models

### Class definitions

    class Person
      include CleanModel::Base

      attribute :first_name
      attribute :last_name
    end

### Usage

    person = Person.new first_name: 'John', last_name: 'Doe'

    person.first_name -> 'John'
    person.last_name  -> 'Doe'

    person.attributes -> {first_name: 'John', last_name: 'Doe'}

    person.assign_attributes first_name: 'Jorge'

    person.attributes -> {first_name: 'Jorge', last_name: 'Doe'}

### Defaults

    class Person
      include CleanModel::Base

      attribute :first_name, default: 'John'
      attribute :last_name
    end

    person = Person.new
    person.first_name -> 'John'
    person.last_name  -> nil

### Active Model validations

    class Person
      include CleanModel::Base

      attribute :first_name
      attribute :last_name

      validates_presence_of :first_name, :last_name
    end

    person = Person.new
    person.valid? -> false

### Strong typing

    class Engine
      include CleanModel::Base

      attribute :power, class_name: :numeric
      attribute :cylinders, class_name: :integer
      attribute :valves, class_name: 'Integer'
    end

    engine = Engine.new
    engine.power = 130
    engine.cylinders = 6.1 -> Raise error CleanModel::InvalidTypeAssignment

### Transformations

    class Car
      include CleanModel::Base

      attribute :brand
      attribute :model
      attribute :engine, class_name: 'Engine'
      attribute :comfort, transformation: lambda { |v| v.is_a?(String) ? v.split(',').map(&:strip) : v }
    end

    car = Car.new do |c|
      c.engine = {power: 110, cylinders: 16, valves: 6}
    end
    car.engine -> <Engine @power=110, @cylinders=16, @valves=6>

    car = Car.new do |c|
      c.comfort = 'bluetooth, gps, electric pack'
    end
    car.comfort -> ['bluetooth', 'gps', 'electric pack']

### Collections

    class Factory
      include CleanModel::Base

      attribute :cars, collection: 'Car'
    end

    factory = Factory.new do |f|
      f.cars = [
        {brand: 'Honda', model: 'Civic'},
        {brand: 'Toyota', model: 'Corolla'},
      ]
    end

    factory.cars -> [<Car @brand=Honda, @model=Civic>, <Car @brand=Toyota, @model=Corolla>]

## Models with custom persistence

### Definition

    class Post
      include CleanModel::Persistent

      attribute :subject
      attribute :content

      private

      def create
        ...
      end

      def update
        ...
      end

      def delete
        ...
      end
    end

### Usage

    Post.create(subject: 'Title', content: 'Some text')
    or
    post = Post.new subject: 'Title', content: 'Some text'
    post.save

    post.content = 'Another text'
    post.save

    post.update_attributes(title: 'Another title')

    post.destroy

## Remote models (for REST APIs)

### Definition

    class User
      include CleanModel::Remote

      connection host: 'localhost', port: 9999

      attribute :first_name
      attribute :last_name
      attribute :email

      def self.find(id)
        connection.get "/users/#{id}.json" do |response|
          new JSON.parse(response.body)
        end
      end

      private

      def create
        connection.post! '/users/create.json', wrapped_attributes
      end

      def update
        connection.put! "/users/#{id}.json", wrapped_attributes(except: :id)
      end

      def delete
        connection.delete!("/users/#{id}.json")
      end
    end

### Usage

    User.create first_name: 'John', last_name: 'Doe'

    user = User.find(1)

    user.update_attributes(first_name: 'Jorge')

    user.destroy

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
