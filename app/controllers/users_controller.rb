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
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    @user.update_aatributes(params[:user])
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

