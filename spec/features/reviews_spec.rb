require 'spec_helper'

describe "reviews requests" do
=begin
  def log_in(params = {})
    if params[:admin] == true
      user = create(:admin)
    else
      user = create(:user)
    end
    user = create(:user)
    visit login_path
    fill_in 'Email', :with => user.email
    fill_in 'Password', :with => user.password
    click_link 'Submit'
    expect(page).to have_content("Logged in!")
  end
=end

  it "cannot edit review as a non-admin" do
    #include 'support/helpers'
    user = FactoryGirl::build(:user)
    #debugger
    visit login_path
    fill_in 'Email', :with => user.email
    fill_in 'Password', :with => user.password
    click_link 'Submit'
    expect(page).to have_content("Logged in!")

    log_in(:admin =>false)
    review = create(:review)
    visit edit_review_path(review)
    expect(page).to have_content("Not authorized")
  end
end
