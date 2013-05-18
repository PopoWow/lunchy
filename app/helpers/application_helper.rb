# encoding: UTF-8

module ApplicationHelper

  # Helper function that returns an HTML div block that
  # defines the user navigation links.  If a user is
  # logged in, it returns links for edit user/log out.
  # Otherwise, it displays links to log in/sign up.
  #
  # * *Args*    :
  #   - None
  # * *Returns* :
  #   - <div> of history user navigation links which
  #     depends on whether a user is logged in or not.
  # * *Raises* :
  #   - None
  #
  def user_navigator
    content_tag(:div, :class => :user_navigator) do
      if current_user
        raw("Hi #{link_to current_user.nickname, edit_user_path(current_user)} | " \
            "#{link_to "Log out", logout_path}")
      else
        raw "#{link_to "Log in", login_path} | #{link_to "Sign up", signup_path}"
      end
    end
  end

  # Helper function that returns an HTML div block that
  # defines the history navigation links.  Internally
  # this uses the @history data constructed by the
  # various action controllers.  To hide this, set
  # @hide_history_bar to true.
  #
  # * *Args*    :
  #   - None
  # * *Returns* :
  #   - <div> of history links separated by a back arrow
  # * *Raises* :
  #   - None
  #
  def history_navigator
    if not @hide_history_bar
      content_tag(:div, :class => :history_navigator) do
        if @history
          @history.each do |item|
            concat link_to(*item)
            concat ' ← '
          end
        else
          link_to('home', root_path)
        end
      end
    end
  end
end
