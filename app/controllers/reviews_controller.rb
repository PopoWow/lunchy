class ReviewsController < ApplicationController
  before_filter :set_review_target, :only => [:index, :new, :create]
  before_filter :init_history

  # GET /reviews
  # GET /reviews.json
  def index

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @reviews }
    end
  end

  def index_all
    @reviews =  Review.includes(:reviewable, :user)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @reviews }
    end
  end

  # GET /reviews/1
  # GET /reviews/1.json
  def show
    @review = Review.includes(:reviewable).find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @review }
    end
  end

  # GET /reviews/new
  # GET /reviews/new.json
  def new
    set_history

    @review = Review.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @review }
    end
  end

  # GET /reviews/1/edit
  def edit
    set_history
    @review = Review.find(params[:id])
  end

  # POST /reviews
  # POST /reviews.json
  def create
    #debugger

    @review = Review.new(params[:review])
    @review.reviewable = @review_target
    @review.user = current_user

    respond_to do |format|
      if @review.save
        format.html { redirect_to @review, notice: 'Review was successfully created.' }
        format.json { render json: @review, status: :created, location: @review }
      else
        format.html { render action: "new" }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /reviews/1
  # PUT /reviews/1.json
  def update
    @review = Review.find(params[:id])

    respond_to do |format|
      if @review.update_attributes(params[:review])
        format.html { redirect_to @review, notice: 'Review was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /reviews/1
  # DELETE /reviews/1.json
  def destroy
    @review = Review.find(params[:id])
    @review.destroy

    respond_to do |format|
      format.html { redirect_to reviews_url }
      format.json { head :no_content }
    end
  end

  def set_review_target
    if /restaurant/ =~ request.path and params[:restaurant_id]
      @review_target = Restaurant.find(params[:restaurant_id])
    elsif /dish/ =~ request.path and params[:dish_id]
      @review_target = Dish.includes(:restaurant).find(params[:dish_id])
    end

    @review_target || not_found
  end

  def set_history
    raise ArgumentError unless @review_target

    if @review_target.respond_to? :restaurant
      add_to_history(@review_target.restaurant.name, restaurant_path(@review_target.restaurant))
      add_to_history('dishes', restaurant_dishes_path(@review_target.restaurant))
    end
    add_to_history(@review_target.name, polymorphic_path(@review_target))
  end
end
