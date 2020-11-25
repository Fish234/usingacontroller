class CarsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_car, only: [:show, :edit, :update, :destroy]

  WHEEL_USAGE_WARNING_THRESHOLD = 0.8

  # GET /cars
  # GET /cars.json
  def index
    @cars = Car.all
  end

  # GET /cars/1
  # GET /cars/1.json
  def show
  end

  # GET /cars/new
  def new
    @car = Car.new
  end

  # GET /cars/1/edit
  def edit
  end

  # POST /cars
  # POST /cars.json
  def create
    @car = Car.new(car_params)

    respond_to do |format|
      if @car.save
        format.html { redirect_to @car, notice: 'Car was successfully created.' }
        format.json { render :show, status: :created, location: @car }
      else
        format.html { render :new }
        format.json { render json: @car.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cars/1
  # PATCH/PUT /cars/1.json
  def update
    respond_to do |format|
      if @car.update(car_params)
        format.html { redirect_to @car, notice: 'Car was successfully updated.' }
        format.json { render :show, status: :ok, location: @car }
      else
        format.html { render :edit }
        format.json { render json: @car.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cars/1
  # DELETE /cars/1.json
  def destroy
    @car.destroy
    respond_to do |format|
      format.html { redirect_to cars_url, notice: 'Car was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def full_model
    @car = Car.find(params[:id])

    car_full_model_string = "#{@car.make} #{@car.model} #{@car.year}"
    render json: { full_model: car_full_model_string }
  end

  def available_trunk_space
    @car = Car.find(params[:id])
    space = @car.max_trunk_space - @car.current_trunk_usage
    render json: { available_trunk_space: space }
  end

  def kilometers_before_wheel_change
    @car = Car.find(params[:id])
    kms = @car.max_wheel_usage_before_change - @car.current_wheel_usage
    render json: { kilometers_before_wheel_change: kms }
  end

  def store_in_trunk
    @car = Car.find(params[:id])
    to_store = params[:amount_to_store].to_i

    if (@car.current_trunk_usage + to_store) <= @car.max_trunk_space
      @car.update!(current_trunk_usage: @car.current_trunk_usage + to_store)
      render json: { car: @car }
    else
      raise RuntimeError, 'Cannot store requested amount, total exceeds maximum storage'
    end
  end

  def wheel_usage_status
    @car = Car.find(params[:id])

    if (@car.current_wheel_usage / @car.max_wheel_usage_before_change) >= WHEEL_USAGE_WARNING_THRESHOLD
      render json: { message: 'Please change your wheels' }
    else
      render json: { message: 'Wheels are OK, you can keep using them' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_car
      @car = Car.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def car_params
      params.require(:car).permit(:make, :model, :year, :kilometers, :max_trunk_space, :current_trunk_usage, :wheel_usage, :max_wheel_usage_before_change)
    end
end
