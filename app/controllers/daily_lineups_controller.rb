class DailyLineupsController < ApplicationController
  # GET /daily_lineups
  # GET /daily_lineups.json
  def index
    @daily_lineups = DailyLineup.includes(:early_1, :early_2, :early_3,
                                          :late_1,  :late_2,  :late_3)

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

    if not @lineup
      # there was no lineup found.  Either because the ID is bad or there just isn't
      # information available for "today".  Show error page witha link back to the
      # last valid lineup in case user want to review something.
      @previous = DailyLineup.where("date < :today", {:today => Date.today}).
                              order(:date).reverse_order # relation
      render :blank
      return
    end

    @previous = DailyLineup.where("date < :today", {:today => @lineup.date}).
                            order(:date).reverse_order # relation
    @next = DailyLineup.where("date > :today", {:today => @lineup.date}).
                        order(:date) # relation

    # Add some additional information to display in the view.
    @lineup.early_1.heading = "Early 1"
    @lineup.early_2.heading = "Early 2"
    @lineup.early_3.heading = "Early 3"
    @lineup.late_1.heading = "Late 1"
    @lineup.late_2.heading = "Late 2"
    @lineup.late_3.heading = "Late 3"

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
end
