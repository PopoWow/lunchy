module RatableHelper
  def rate
    find_ratable

    @response = {}

    # check and see if the item is changed or new.
    if @query.exists?
      @response[:notice] = "Rating changed from #{@rating.value} to #{params[:rating]}"
    else
      @response[:notice] = "Thank you for rating this dish!"
    end
    @rating.value = params[:rating]
    @rating.save!

    # need to set this AFTER the save!  Otherwise modifed timestamp is outdated!
    @response[:target] = @rate_target

    render "shared/rate"
  end

  def find_ratable
    where_terms = {:user_id => current_user}
    if /restaurant/ =~ request.path and params[:restaurant_id]
      @rate_target = Restaurant.find(params[:restaurant_id])
      where_terms.merge! :ratable_id => params[:restaurant_id], :ratable_type => 'Restaurant'
    elsif /dish/ =~ request.path and params[:dish_id]
      @rate_target = Dish.find(params[:dish_id])
      where_terms.merge! :ratable_id => params[:dish_id], :ratable_type => 'Dish'
    end
    # if we can't find the rating target, we're done.
    @rate_target || not_found

    @query = Rating.where(where_terms)
    @rating = @query.first_or_initialize
  end
end