class UserMailer < ActionMailer::Base
  default from: "Lunchy Munchy <lunchymunchy.notification@gmail.com>"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activation_needed_email.subject
  #

  SITENAME = "Lunchy Munchy"

  def activation_needed_email(user)
    @user = user
    @sitename = SITENAME
    @url  = "http://lunchy.munchy.com:3000/users/#{user.activation_token}/activate"

    mail(:to => "#{@user.nickname} <#{@user.email}>",
         :subject => "Activate your account!")
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.user_mailer.activation_success_email.subject
  #
  def activation_success_email(user)
    @user = user
    @sitename = SITENAME
    @url  = "http://lunchy.munchy.com:3000/login"

    mail(:to => "#{@user.nickname} <#{@user.email}>",
         :subject => "Your account is activated!")
  end

  def reset_password_email(user)
    @user = user
    # need to set this for this this to work.
    #config.action_mailer.default_url_options = { :host => "yourhost" }
    #@url = edit_password_reset_url()
    @url  = "http://lunchy.munchy.com:3000/password_resets/#{user.reset_password_token}/edit"
    mail(:to => "#{@user.nickname} <#{@user.email}>",
         :subject => "Request to reset password was received!")
  end
end
