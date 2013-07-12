require 'spec_helper'

describe User do
  it "is valid with a nickname, email and password" do
    user = User.new(:nickname => 'Fuzzy McKitty',
                    :email => 'foo@bar.com',
                    :password => 'secret')
    expect(user).to be_valid
  end
  it "is invalid without a nickname" do
    expect(User.new(:nickname => nil)).to have(1).errors_on(:nickname)
    #user = User.new(:email => 'foo@bar.com', :password => 'secret')
  end
  it "is invalid without an email" do
    expect(User.new(:email => nil)).to have(1).errors_on(:email)

  end
  it "is invalid without a password" do
    expect(User.new(:password => nil)).to have(1).errors_on(:password)

  end
  it "is valid if password is 3 characters" do
    user = User.new(:nickname => 'Fuzzy McKitty',
                    :email => 'foo@bar.com',
                    :password => '123')
    expect(user).to be_valid

  end
  it "is invalid if password is 2 characters" do
    user = User.new(:nickname => 'Fuzzy McKitty',
                    :email => 'foo@bar.com',
                    :password => '12')
    expect(user).to have(1).errors_on(:password)

  end
end
