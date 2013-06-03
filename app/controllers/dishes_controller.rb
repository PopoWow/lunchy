class DishesController < ApplicationController
  include RatableHelper
  include FeedbackManager

  before_filter :init_history, :only => [:index, :show]

  # GET /restaurants/:id/dishes
  # GET /restaurants/:id/dishes.json
  def index
    @restaurant = Restaurant.find(params[:restaurant_id])
    add_to_history(@restaurant.name, restaurant_path(@restaurant))

    # Get all the ratings for this restaurant.  Calculates
    # the dish_ids from all courses and then does a query
    # using that list.  Stores the rating info in a list
    # that is referred to by the view to populate the
    # initial state of the rating select_tags
    active_dishes = []
    @restaurant.active_courses.includes(:active_dishes).each do |course|
      # tried using active_dishes.pluck(:id) but I didn't like how that
      # was causing n+1 queries...
      active_dishes.concat(course.active_dishes)
    end

    query_user_feedback_for_items(active_dishes)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @dishes }
    end
  end

  # GET /dishes/1
  # GET /dishes/1.json
  def show
    @dish = Dish.find(params[:id])
    add_to_history(@dish.restaurant.name, restaurant_path(@dish.restaurant))
    add_to_history('dishes', restaurant_dishes_path(@dish.restaurant))

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @dish }
    end
  end

  # GET /dishes/new
  # GET /dishes/new.json
  def new
    @dish = Dish.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @dish }
    end
  end

  # GET /dishes/1/edit
  def edit
    @dish = Dish.find(params[:id])
  end

  # POST /dishes
  # POST /dishes.json
  def create
    @dish = Dish.new(params[:dish])

    respond_to do |format|
      if @dish.save
        format.html { redirect_to @dish, notice: 'Dish was successfully created.' }
        format.json { render json: @dish, status: :created, location: @dish }
      else
        format.html { render action: "new" }
        format.json { render json: @dish.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /dishes/1
  # PUT /dishes/1.json
  def update
    @dish = Dish.find(params[:id])

    respond_to do |format|
      if @dish.update_attributes(params[:dish])
        format.html { redirect_to @dish, notice: 'Dish was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @dish.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dishes/1
  # DELETE /dishes/1.json
  def destroy
    @dish = Dish.find(params[:id])
    @dish.destroy

    respond_to do |format|
      format.html { redirect_to dishes_url }
      format.json { head :no_content }
    end
  end

end
