module DishesHelper
  def get_rating_id(dish_id)
    @user_ratings[dish_id] && @user_ratings[dish_id][0]
  end

  def get_rating(dish_id)
    @user_ratings[dish_id] && @user_ratings[dish_id][1]
  end
end
