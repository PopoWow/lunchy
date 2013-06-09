FactoryGirl.define do
  factory :user do
    # Creates an normal user.  ex: create(:user)
    sequence(:nickname) {|seq| "foobsky#{seq}"}
    password = "123"
    email {"#{nickname}@bar.com"}
    admin = false

    factory :admin do
      # Creates an "admin" user.  ex: create(:admin)
      factory = true
    end
  end
end