FactoryGirl.define do
  factory :user do
    sequence(:nickname) {|seq| "foobsky#{seq}"}
    password = "123"
    email {"#{nickname}@bar.com"}
  end
end