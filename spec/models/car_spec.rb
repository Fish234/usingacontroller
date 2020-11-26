require 'rails_helper'

RSpec.describe Car, type: :model do
  describe 'Car model spec' do
    let(:car) do
      Car.create(make: 'Toyota', model: 'Yaris', year: 2019,
                kilometers: 1000, max_wheel_usage_before_change: 12000,
                max_trunk_space: 100)
    end
    context 'basic methods' do
      it 'should return basic model info' do
        expect(car.make).to eq 'Toyota'
        expect(car.model).to eq 'Yaris'
      end
    end

  end

  describe 'Custom methods' do
    let(:car) do
      Car.create(make: 'Toyota', model: 'Yaris', year: 2019,
                kilometers: 1000, max_wheel_usage_before_change: 12000,
                max_trunk_space: 100)
    end
    context 'full model method' do
      it 'returns a full model string' do
        expect(car.full_model).to eq 'Toyota Yaris 2019'
      end
    end

    context 'available trunk space method' do
      it 'returns a available trunk space' do
        expect(car.available_trunk_space).to eq 100
        car.update(current_trunk_usage: 50)
        expect(car.available_trunk_space).to eq 50
      end
    end

    context 'Kilometers before wheel change method' do
      it 'returns kilometers before wheel change' do
        expect(car.kilometers_before_wheel_change).to eq 12000
        car.update(current_wheel_usage: 6000)
        expect(car.kilometers_before_wheel_change).to eq 6000
      end
    end

    context 'Store in trunk method' do
      it 'update current trunk usage < limit' do
        car.store_in_trunk(50)
        expect(car.current_trunk_usage).to eq 50
      end

      it 'store in trunk fails when current trunk usage > limit' do
        expect{car.store_in_trunk(150) }.to raise_error(RuntimeError)
      end
    end

    context 'wheel usage status method' do
      it 'return wheel usage status when usage status > wheel usage warning threshold' do
        car.update(current_wheel_usage: 12000)
        expect(car.wheel_usage_status).to eq 'Please change your wheels'
      end

      it 'return wheel usage status when usage status < wheel usage warning threshold' do
        car.update(current_wheel_usage: 6000)
        expect(car.wheel_usage_status).to eq 'Wheels are OK, you can keep using them'
      end
    end
  end
end
