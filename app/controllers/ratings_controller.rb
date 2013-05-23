class RatingsController < ApplicationController
  before_filter :find_ratable

  def delete
    @response = {}

    if @query.exists?
      @response[:notice] = "Rating removed"
      @rating.delete

      @response[:target] = @rate_target

      render :rate
    else
      head :no_content
    end
  end
end
