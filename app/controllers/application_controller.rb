class ApplicationController < ActionController::Base
  protect_from_forgery

  def not_found
    raise ActionController::RoutingError.new('Not Found')
  end

  def init_history
    @history = []
    if session[:lineup_id]
      @lineup = DailyLineup.find(session[:lineup_id])
      @history << ["lineup for #{@lineup.date}", lineups_path(@lineup)]
    else
      @history << ['home', root_path]
    end
  end

  def add_to_history(label, path)
    @history << [label, path]
  end

end
