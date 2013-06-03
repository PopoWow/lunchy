module FeedbackManager

  def query_user_feedback_for_items(feedbackables)
    return if not current_user
    return if feedbackables.empty?

    klass = feedbackables.first.class
    class_name = klass.to_s
    table_name = klass.table_name

    # use Ratings as the root, I guess.  it doesn't really matter
    reviews_info =
      Review.select(%Q[reviewable_id, id AS review_id]).
             #joins(%Q[INNER JOIN #{table_name} ON reviews.reviewable_id = #{table_name}.id AND reviews.reviewable_type = '#{class_name}']).
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
             #joins(%Q[INNER JOIN #{table_name} ON ratings.ratable_id = #{table_name}.id AND ratings.ratable_type = '#{class_name}']).
             where(:user_id => current_user).
             where(:ratable_id => feedbackables).
             where(:ratable_type => class_name).
             all
    ratings_hash = {}
    ratings_info.each do |item|
      ratings_hash[item.attributes["ratable_id"]] = {:rating_id => item.attributes["rating_id"],
                                                     :rating_value => item.attributes["rating_value"]}
    end

    @user_feedback = reviews_hash.deep_merge(ratings_hash)
  end

  def get_user_review_id(reviewable)
    get_cached_feedback_info(reviewable, :review_id) do
      current_user.get_review_info(reviewable, :id)
    end
  end

  def get_user_rating_id(ratable)
    get_cached_feedback_info(ratable, :rating_id) do
      current_user.get_rating_info(ratable, :id)
    end
  end

  def get_user_rating_value(ratable)
    get_cached_feedback_info(ratable, :rating_value) do
      current_user.get_rating_info(ratable, :value)
    end
  end

  def get_user_review_link(reviewable)
    review_id = get_user_review_id(reviewable)
    if review_id
      link_to 'Edit Review', edit_review_path(review_id)
    else
      link_to 'Write Review', polymorphic_path(['new', reviewable, 'review'])
    end
  end

  private
  def get_cached_feedback_info(feedbackable, info_name)
    if defined? @user_feedback
      @user_feedback[feedbackable.id][info_name] if @user_feedback[feedbackable.id]
    elsif current_user
      yield
    end
  end

end