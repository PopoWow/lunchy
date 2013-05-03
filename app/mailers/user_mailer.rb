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

    mail(:to => "#{@user.nickname} <#{@user.email}>", :subject => "Activate your account!")
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

    mail(:to => "#{@user.nickname} <#{@user.email}>", :subject => "Your account is acvivated!")
  end
end
