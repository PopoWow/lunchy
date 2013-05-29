module DailyLineupsHelper
  def get_ratings_for_current_user(lineup_id)
    if current_user
      qres = DailyLineup.select("restaurants.id as restaurant_id, ratings.id as rating_id, ratings.value as rating_value").
                         joins(:restaurants).
                         joins(%Q[INNER JOIN ratings ON ratings.ratable_id = restaurants.id
                                  INNER JOIN users ON users.id = ratings.user_id]).
                         where([%Q[daily_lineups.id = ? and users.id = ?"],
                               lineup_id, current_user.id])
      results = {}
      qres.each do |rating_info|
        results[rating_info.restaurant_id] = [rating_info.rating_id, rating_info.rating_value]
      end

      results if results.any?
    end
  end

  def get_user_rating_value(ratable_id)
    if ratable_id.respond_to? :id
      ratable_id = ratable_id.id
    end

    key = ratable_id.to_s
    if @feedback_info and @feedback_info[ratable_id.to_s]
      return @feedback_info[ratable_id.to_s][:rating_value]
    end
  end

  def get_user_review_id(reviewable_id)
    if reviewable_id.respond_to? :id
      reviewable_id = reviewable_id.id
    end

    key = reviewable_id.to_s
    if @feedback_info and @feedback_info[key]
      return @feedback_info[key][:review_id]
    end
  end

end
