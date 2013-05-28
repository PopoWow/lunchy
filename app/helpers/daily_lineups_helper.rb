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

end
