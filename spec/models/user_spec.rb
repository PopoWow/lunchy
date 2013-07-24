require 'spec_helper'

describe User do
  it "has a valid factory" do
    expect(build :user).to be_valid
  end

  it "is invalid without a nickname" do
    expect(build(:user, :nickname => nil)).to have(1).errors_on(:nickname)
    #user = User.new(:email => 'foo@bar.com', :password => 'secret')
  end

  it "is invalid without an email" do
    expect(build(:user, :email => nil)).to have(1).errors_on(:email)
  end

  it "is invalid without a password" do
    expect(build(:user, :password => nil)).to have(1).errors_on(:password)
  end

  it "is valid if password is 3 characters" do
    user = build(:user, :password => '123')
    expect(user).to be_valid
  end

  it "is invalid if password is 2 characters" do
    user = build(:user, :password => '12')
    expect(user).to have(1).errors_on(:password)
  end

  # the next suite relies on a user existing and checking against duplicate fields
  describe "with existing users" do
    before :each do
      @user1 = create(:user)
    end

    context "distinct nickname and email" do
      it "is valid" do
        user2 = build(:user)
        expect(user2).to be_valid
      end
    end

    context "duplicate nickname" do
      it "is invalid" do
        user2 = build(:user, :nickname => @user1.nickname)
        expect(user2).to have(1).errors_on(:nickname)
      end
    end

    context "duplicate email" do
      it "is invalid" do
        user2 = build(:user, :email => @user1.email)
        expect(user2).to have(1).errors_on(:email)
      end
    end
  end
end
