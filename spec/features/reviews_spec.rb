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
    #log in (move to helper)
    user = create(:user)
    visit login_path
    fill_in 'Email', :with => user.email
    fill_in 'Password', :with => '123'
    click_button 'Log in'
    expect(page).to have_content("Logged in!")

    diff_user = create(:user)
    review = create(:restaurant_review, :user => diff_user)
    visit review_path(review)
    save_and_open_page

=begin
    log_in(:admin =>false)
    review = create(:review)
    visit edit_review_path(review)
    expect(page.reload).to have_content("Not authorized")
=end
  end
end
