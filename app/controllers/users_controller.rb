class UsersController < ApplicationController
  skip_before_filter :require_login, :only => [:new, :create, :activate]

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to root_url, :notice => "Signed up!  Please activate your account."
    else
      render :new
    end
  end

  def edit
    @user = current_user
  end

  def update
    @user = User.find(params[:id])
    if current_user != @user
    end

    user_info = params[:user]
    ignore_password_info = user_info[:old_password].empty? and  user_info[:password].empty? and
                           user_info[:password_confirmation].empty?
    if ignore_password_info
      params[:user].delete :password
      params[:user].delete :password_confirmation
    else
      passwords_match = @user.check_password(params[:user][:old_password])
      if not passwords_match
        @user = current_user
        redirect_to edit_user_path(@user), :notice => "Old password does not match"
        return
      end
    end

    params[:user].delete :old_password

    if @user.update_attributes(params[:user])
      redirect_to root_url, notice: 'User was successfully updated.'
    else
      render action: "edit"
    end
  end

  def activate
    #debugger
    @user = User.load_from_activation_token(params[:id])
    if @user
      @user.activate!
      redirect_to login_url, :notice => "Successfully activated.  Thank you!"
    else
      not_authenticated
      #redirect_to root_url, :notice => "Account activation failed."
    end
  end
end

