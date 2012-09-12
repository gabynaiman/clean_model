require 'spec_helper'

describe CleanModel::Base do

  context 'Basic attributes access' do

    subject { BaseModels::Person.new }

    it 'Respond to each defined attribute' do
      should respond_to 'first_name'
      should respond_to 'first_name='
      should respond_to 'last_name'
      should respond_to 'last_name='
    end

    it 'Keep value of attributes' do
      person = BaseModels::Person.new

      person.first_name.should be_nil
      person.first_name = 'John'
      person.first_name.should eq 'John'

      person.last_name.should be_nil
      person.last_name = 'Doe'
      person.last_name.should eq 'Doe'
    end

    it 'Can assign attributes via constructor hash' do
      person = BaseModels::Person.new first_name: 'John', last_name: 'Doe'
      person.first_name.should eq 'John'
      person.last_name.should eq 'Doe'
    end

    it 'Can assign attributes via constructor block' do
      person = BaseModels::Person.new do |p|
        p.first_name = 'John'
        p.last_name = 'Doe'
      end
      person.first_name.should eq 'John'
      person.last_name.should eq 'Doe'
    end

    it 'Get attributes hash' do
      person = BaseModels::Person.new first_name: 'John', last_name: 'Doe'
      person.attributes.keys.should eq [:first_name, :last_name]
      person.attributes[:first_name].should eq 'John'
      person.attributes[:last_name].should eq 'Doe'
    end

  end

  context 'Strong typed attributes restrictions' do

    it 'Type defined with a symbol' do
      engine = BaseModels::Engine.new
      engine.cylinders = 6
      expect { engine.cylinders = 6.5 }.to raise_error CleanModel::InvalidTypeAssignment
    end

    it 'Type defined with a string' do
      engine = BaseModels::Engine.new
      engine.valves = 16
      expect { engine.valves = 16.5 }.to raise_error CleanModel::InvalidTypeAssignment
    end

    it 'Type defined with a super class' do
      engine = BaseModels::Engine.new
      engine.power = 130
      expect { engine.power = '130hp' }.to raise_error CleanModel::InvalidTypeAssignment
    end

  end

  context 'Attribute type conversions' do

    it 'Transform to model when assign a hash' do
      car = BaseModels::Car.new do |c|
        c.engine = {power: 110, cylinders: 16, valves: 6}
      end
      car.engine.should be_a BaseModels::Engine
      car.engine.power.should eq 110
      car.engine.cylinders.should eq 16
      car.engine.valves.should eq 6
    end

    it 'Apply custom transformation' do
      car = BaseModels::Car.new do |c|
        c.comfort = 'bluetooth, gps, electric pack'
      end
      car.comfort.should be_a Array
      car.comfort.should eq ['bluetooth', 'gps', 'electric pack']
    end

    it 'Transform array elements when collection defined' do
      factory = BaseModels::Factory.new do |f|
        f.cars = [
            {brand: 'Honda', model: 'Civic'},
            {brand: 'Toyota', model: 'Corolla'},
        ]
      end

      factory.cars.should be_a Array
      factory.cars.should have(2).items

      factory.cars[0].should be_a BaseModels::Car
      factory.cars[0].brand.should eq 'Honda'
      factory.cars[0].model.should eq 'Civic'

      factory.cars[1].should be_a BaseModels::Car
      factory.cars[1].brand.should eq 'Toyota'
      factory.cars[1].model.should eq 'Corolla'
    end

  end

  context 'Active model naming and translation' do

    it 'Get a model name' do
      BaseModels::Person.model_name.should eq 'BaseModels::Person'
      BaseModels::Person.model_name.human.should eq 'Person'
    end

    it 'Get a human attribute names' do
      BaseModels::Person.human_attribute_name(:first_name).should eq 'First name'
      BaseModels::Person.human_attribute_name(:last_name).should eq 'Last name'
    end

  end

  context 'Active model validations' do

    it 'Validates presence' do
      BaseModels::Person.new(first_name: 'John', last_name: 'Doe').should be_valid

      person = BaseModels::Person.new
      person.should_not be_valid
      person.errors[:first_name].should have(1).items
      person.errors[:last_name].should have(1).items
    end

  end

end