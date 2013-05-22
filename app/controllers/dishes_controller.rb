class DishesController < ApplicationController
  before_filter :init_history, :only => [:index, :show]

  # GET /dishes
  # GET /dishes.json
  def index
    @restaurant = Restaurant.find(params[:restaurant_id])
    add_to_history(@restaurant.name, restaurant_path(@restaurant))

    dish_ids = []
    @restaurant.active_courses.includes(:active_dishes).each do |course|
      dish_ids << course.active_dishes.pluck(:id)
    end
    dish_ids.flatten!

    conditions = {:user_id => current_user,
                  :ratable_type => 'Dish',
                  :ratable_id => dish_ids}
    user_ratings = Rating.where(conditions).all
    @user_ratings = {}

    user_ratings.each do |rating|
      @user_ratings[rating.ratable_id] = rating.value
    end

    #debugger

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

  def rate
    query = Rating.where(:user_id => current_user,
                         :ratable_id => params[:dish_id],
                         :ratable_type => "Dish")
    rating = query.first_or_initialize

    # check and see if the item is changed or new.
    @response = {:dish => Dish.find(params[:dish_id]) }
    if query.exists?
      @response[:notice] = "Rating changed from #{rating.value} to #{params[:rating]}"
    else
      @response[:notice] = "Thank you for rating this dish!"
    end

    rating.value = params[:rating]
    rating.save!

    render :rate
  end
end
