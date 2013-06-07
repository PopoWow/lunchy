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
    select_term ||= %Q[reviews.id AS review_id, reviews.user_id AS review_user_id, reviews.reviewable_id,
                         reviews.title, reviews.content, reviews.updated_at AS review_udpated_at,
                       users.id AS user_id, users.nickname,
                       ratings.id AS rating_id, ratings.user_id AS rating_user_id, ratings.ratable_id AS ratable_id,
                         ratings.value, ratings.updated_at AS rating_updated_at]
    join_term = %Q[INNER JOIN reviews ON users.id = reviews.user_id AND
                                         reviews.reviewable_id = #{id} AND
                                         reviews.reviewable_type = '#{self.class.to_s}'
                   LEFT OUTER JOIN ratings ON users.id = ratings.user_id AND
                                              ratings.ratable_id = #{id} AND
                                              ratings.ratable_type = '#{self.class.to_s}']
    User.select(select_term).
         joins(join_term)
=begin
         .
         where(%Q[(reviews.reviewable_id = :id AND reviews.reviewable_type = :type) OR
                  (ratings.ratable_id    = :id AND ratings.ratable_type    = :type)],
               {:id => id, :type => self.class.to_s})
=end
  end
end
=begin
Review.select(select_term).
       joins(%Q[FULL OUTER JOIN ratings ON reviews.user_id = ratings.user_id]).
       where(%Q[(reviews.reviewable_id = :id AND reviews.reviewable_type = :type) OR
                (ratings.ratable_id    = :id AND ratings.ratable_type    = :type)],
             {:id => id, :type => type.class.to_s})
=end