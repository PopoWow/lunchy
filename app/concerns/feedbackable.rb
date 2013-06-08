require 'active_support/concern'

module Feedbackable
  extend ActiveSupport::Concern

  def valid_rating_average
    # to round to the nearest half star
    #(val * 2).round / 2.0

    ratings.where("value != '0'").average(:value).to_f.round(1)
  end

  def valid_rating_count
    ratings.where("value != '0'").count
  end

  def get_review(current_user)
    if current_user
      reviews.where(:user_id => current_user).first
    end
  end

  def get_review_info(current_user, field)
    review = get_review(current_user)
    if review and review.respond_to? field
      review.send(field)
    end
  end

  def get_rating(current_user)
    if current_user
      ratings.where(:user_id => current_user).first
    end
  end

  def get_rating_info(current_user, field)
    rating = get_rating(current_user)
    if rating and rating.respond_to? field
      rating.send(field)
    end
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
  end

  module ClassMethods
    def collate_user_feedback_for_items(current_user, feedbackables)
      return if not current_user
      return if feedbackables.empty?

      klass = feedbackables.first.class
      class_name = klass.to_s

      # use Ratings as the root, I guess.  it doesn't really matter
      reviews_info =
        Review.select(%Q[reviewable_id, id AS review_id]).
               where(:user_id => current_user).
               where(:reviewable_id => feedbackables).
               where(:reviewable_type => class_name).
               all
      reviews_hash = {}
      reviews_info.each do |item|
        reviews_hash[item.attributes["reviewable_id"]] = {:review_id => item.attributes["review_id"]}
      end

      ratings_info =
        Rating.select(%Q[ratable_id, ratings.id AS rating_id, ratings.value AS rating_value]).
               where(:user_id => current_user).
               where(:ratable_id => feedbackables).
               where(:ratable_type => class_name).
               all
      ratings_hash = {}
      ratings_info.each do |item|
        ratings_hash[item.attributes["ratable_id"]] = {:rating_id => item.attributes["rating_id"],
                                                       :rating_value => item.attributes["rating_value"]}
      end

      reviews_hash.deep_merge(ratings_hash)
    end
  end
end
