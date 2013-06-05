module Feedbackable
  def valid_rating_average
    # to round to the nearest half star
    #(val * 2).round / 2.0

    ratings.where("value != '0'").average(:value).to_f.round(1)
  end

  def valid_rating_count
    ratings.where("value != '0'").count
  end

  def feedbacks
    select_term = %Q[reviews.id AS review_id, reviews.user_id AS review_user_id, reviews.reviewable_id AS reviewable_id,
                     ratings.id AS rating_id, ratings.user_id AS rating_user_id, ratings.ratable_id AS ratable_id]
    select_term = "*"
    Review.select(select_term).
           joins(%Q[FULL OUTER JOIN ratings ON reviews.user_id = ratings.user_id]).
                    #INNER JOIN users ON (users.id = reviews.user_id OR users.id = ratings.user_id)]).
           where(%Q[(reviews.reviewable_id = :id AND reviews.reviewable_type = :type) OR
                    (ratings.ratable_id    = :id AND ratings.ratable_type    = :type)],
                 {:id => id, :type => self.class.to_s})
  end
end