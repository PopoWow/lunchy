module FeedbackManager

  def query_user_feedback_for_items(feedbackables)
    return if not current_user
    return if feedbackables.empty?

    feedbackable_class = feedbackables.first.class
    @user_feedback = feedbackable_class.collate_user_feedback_for_items(current_user, feedbackables)
  end

  def get_user_review_id(reviewable)
    get_cached_feedback_info(reviewable, :review_id) do
      reviewable.get_review_info(current_user, :id)
    end
  end

  def get_user_rating_id(ratable)
    get_cached_feedback_info(ratable, :rating_id) do
      ratable.get_rating_info(current_user, :id)
    end
  end

  def get_user_rating_value(ratable)
    get_cached_feedback_info(ratable, :rating_value) do
      ratable.get_rating_info(current_user, :value)
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
      # if user feedback is set, then return value if any, otherwise nil.
      @user_feedback[feedbackable.id][info_name] if @user_feedback[feedbackable.id]
    elsif current_user
      # no feedback was set, query DB for user's value (modem access method
      # passed in block)
      yield
    end
  end

end