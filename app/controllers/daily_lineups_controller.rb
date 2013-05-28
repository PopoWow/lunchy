class DailyLineupsController < ApplicationController
  # GET /daily_lineups
  # GET /daily_lineups.json
  def index
    @daily_lineups = DailyLineup.includes(:restaurants)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @daily_lineups }
    end

  end

  # GET /daily_lineups/1
  # GET /daily_lineups/1.json
  def show
    # Don't eager load here (firstly because it does no good the way
    # DailyLineup is organized.  EL still runs 6 queries for the 6
    # choices!).  But also, because we're caching each restaurant
    # as a fragment so eager loading it here would be actually
    # wasteful.

    @hide_history_bar = true

    if params["id"] == "today"
      @lineup = DailyLineup.where("date >= :today", {:today => Date.today}).order(:date).first
    else
      begin
        @lineup = DailyLineup.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        @lineup = nil
      end
    end

    # for the rest of these, try using relations so we can lazy load them
    # and take advantage of fragment caching.

    if @lineup
      session[:lineup_id] = @lineup.id
    else
      session[:lineup_id] = nil
      # there was no lineup found.  Either because the ID is bad or there just isn't
      # information available for "today".  Show error page witha link back to the
      # last valid lineup in case user want to review something.
      @previous = DailyLineup.where("date < :today", {:today => Date.today}).
                              order(:date).reverse_order # relation
      render :blank
      return
    end

    get_info_for_current_user(@lineup.id)

    @previous = DailyLineup.where("date < :today", {:today => @lineup.date}).
                            order(:date).reverse_order # relation
    @next = DailyLineup.where("date > :today", {:today => @lineup.date}).
                        order(:date) # relation

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @lineup }
    end
  end

  # GET /daily_lineups/new
  # GET /daily_lineups/new.json
  def new
    @daily_lineup = DailyLineup.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @daily_lineup }
    end
  end

  # GET /daily_lineups/1/edit
  def edit
    @daily_lineup = DailyLineup.find(params[:id])
  end

  # POST /daily_lineups
  # POST /daily_lineups.json
  def create
    @daily_lineup = DailyLineup.new(params[:daily_lineup])

    respond_to do |format|
      if @daily_lineup.save
        format.html { redirect_to @daily_lineup, notice: 'Daily lineup was successfully created.' }
        format.json { render json: @daily_lineup, status: :created, location: @daily_lineup }
      else
        format.html { render action: "new" }
        format.json { render json: @daily_lineup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /daily_lineups/1
  # PUT /daily_lineups/1.json
  def update
    @daily_lineup = DailyLineup.find(params[:id])

    respond_to do |format|
      if @daily_lineup.update_attributes(params[:daily_lineup])
        format.html { redirect_to @daily_lineup, notice: 'Daily lineup was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @daily_lineup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /daily_lineups/1
  # DELETE /daily_lineups/1.json
  def destroy
    @daily_lineup = DailyLineup.find(params[:id])
    @daily_lineup.destroy

    respond_to do |format|
      format.html { redirect_to daily_lineups_url }
      format.json { head :no_content }
    end
  end

  def get_info_for_current_user(lineup_id)
    if not current_user
      return
    end

    if lineup_id.respond_to? :id
      lineup_id = lineup_id.id
    end

    res = DailyLineup.select("restaurants.id AS restaurant_id").
                      joins(:restaurants).
                      where(:id => lineup_id)
    ids = []
    res.each {|item| ids << item.attributes["restaurant_id"]}

    # ids now has a list of restaurant IDs for this lineup.

    # do this with a massive join?
    res = Restaurant.select("restaurants.id AS restaurant_id, ratings.id AS rating_id, ratings.value AS rating_value").
                     joins("INNER JOIN ratings ON restaurants.id = ratings.ratable_id").
                     where("ratings.ratable_type = 'Restaurant'").
                     where("restaurants.id IN (?)", ids).
                     where("ratings.user_id = ?", current_user)
    rating_data = {}
    res.each do |item|
      rating_data[item.attributes["restaurant_id"]] = {:rating_id => item.attributes["rating_id"],
                                                       :rating_value => item.attributes["rating_value"]}
    end

    res = Restaurant.select("restaurants.id AS restaurant_id, reviews.id AS review_id").
                     joins("INNER JOIN reviews ON restaurants.id = reviews.reviewable_id").
                     where("reviews.reviewable_type = 'Restaurant'").
                     where("restaurants.id IN (?)", ids).
                     where("reviews.user_id = ?", current_user)
    review_data = {}
    res.each do |item|
      review_data[item.attributes["restaurant_id"]] = {:review_id => item.attributes["review_id"]}
    end

    @feedback_info = rating_data.deep_merge(review_data)
  end

end
