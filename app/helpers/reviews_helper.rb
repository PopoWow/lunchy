module ReviewsHelper

  def get_form_url(action)
    case action
    when "new", "create"
      # need to handle create here as well due to redirection when validation fails
      polymorphic_path([@review_target, @review])
    when "edit", "update"
      # need to handle update reate here as well due to redirection when validation fails
      review_path(@review)
    else
      # something, i guess.
      review_path(@review)
    end
  end
end
