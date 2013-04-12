class DailyLineupsController < ApplicationController
  # GET /daily_lineups
  # GET /daily_lineups.json
  def index
    @daily_lineups = DailyLineup.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @daily_lineups }
    end
  end

  # GET /daily_lineups/1
  # GET /daily_lineups/1.json
  def show
    @daily_lineup = DailyLineup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @daily_lineup }
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
