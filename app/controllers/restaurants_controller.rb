class RestaurantsController < ApplicationController
  include RatableHelper

  before_filter :init_history, :only => :show

  # GET /restaurants
  # GET /restaurants.json
  def index
    @restaurants = Restaurant.includes(:reviews).all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @restaurants }
    end
  end

  # GET /restaurants/1
  # GET /restaurants/1.json
  def show
    @restaurant = Restaurant.includes(:reviews).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @restaurant }
    end
  end

=begin
  # GET /restaurants/new
  # GET /restaurants/new.json
  def new
    @restaurant = Restaurant.new

    add_to_history(@restaurant.name, restaurant_path(@restaurant))


    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @restaurant }
    end
  end
=end

  # GET /restaurants/1/edit
  def edit
    @restaurant = Restaurant.find(params[:id])
    add_to_history(@restaurant.name, restaurant_path(@restaurant))
  end

  # POST /restaurants
  # POST /restaurants.json
  def create
    @restaurant = Restaurant.new(params[:restaurant])

    respond_to do |format|
      if @restaurant.save
        format.html { redirect_to @restaurant, notice: 'Restaurant was successfully created.' }
        format.json { render json: @restaurant, status: :created, location: @restaurant }
      else
        format.html { render action: "new" }
        format.json { render json: @restaurant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /restaurants/1
  # PUT /restaurants/1.json
  def update
    @restaurant = Restaurant.find(params[:id])

    respond_to do |format|
      if @restaurant.update_attributes(params[:restaurant])
        format.html { redirect_to @restaurant, notice: 'Restaurant was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @restaurant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /restaurants/1
  # DELETE /restaurants/1.json
  def destroy
    @restaurant = Restaurant.find(params[:id])
    @restaurant.destroy

    respond_to do |format|
      format.html { redirect_to restaurants_url }
      format.json { head :no_content }
    end
  end

  # POST /restaurant/1/rate
=begin
  def rate
    query = Rating.where(:user_id => current_user,
                         :ratable_id => params[:restaurant_id],
                         :ratable_type => "Restaurant")
    rating = query.first_or_initialize

    # check and see if the item is changed or new.
    @response = {}
    if query.exists?
      @response[:notice] = "Rating changed from #{rating.value} to #{params[:rating]}"
    else
      @response[:notice] = "Thank you for rating this restaurant!"
    end

    rating.value = params[:rating]
    rating.save!

    @response[:target] = rating.ratable

    render "shared/rate"
  end
=end

end
