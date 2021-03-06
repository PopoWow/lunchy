class DailyLineupsController < ApplicationController
  include FeedbackManager

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
    #debugger

    @hide_history_bar = true

    if params["id"] == "today"
      @lineup = DailyLineup.includes(:schedulings => :restaurant).
                            where("date >= :today", {:today => Date.today}).
                            order(:date).
                            first
    else
      begin
        @lineup = DailyLineup.includes(:schedulings => :restaurant).
                              find(params[:id])
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

    query_user_feedback_for_lineup_restaurants

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



  def query_user_feedback_for_lineup_restaurants()
    return if not current_user
    return if not defined? @lineup

    # call into feedback manager
    query_user_feedback_for_items(@lineup.restaurants)
  end

end
