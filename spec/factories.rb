FactoryGirl.define do
  factory :user do
    # Creates an normal user.  ex: create(:user)
    sequence(:nickname) {|seq| "User#{seq}"}
    password "123"
    email    {"#{nickname}@example.com"}
    admin    false

    after(:create) { |user| user.activate! }

    factory :admin do
      # Creates an "admin" user.  ex: create(:admin)
      admin  true
    end
  end

  factory :restaurant do
    sequence(:name) {|seq| "Restaurant#{seq}"}
    # any other fields?
  end

  factory :scheduling do
    shift 1

    factory :scheduling_with_restaurant do
      restaurant
    end
  end

  factory :daily_lineup do
    date {Date.today}

    factory :daily_lineup_with_schedulings_and_restaurants do
      ignore do
        schedulings_count_per_shift 3
      end

      # the after(:create) yields two values; the user instance itself and the
      # evaluator, which stores all values from the factory, including ignored
      # attributes; `create_list`'s second argument is the number of records
      # to create and we make sure the user is associated properly to the post
=begin
      after(:build) do |lineup, evaluator|
        build_list(:scheduling_with_restaurant, evaluator.schedulings_count_per_shift,
                    :daily_lineup => lineup, :shift => 1)
        build_list(:scheduling_with_restaurant, evaluator.schedulings_count_per_shift,
                    :daily_lineup => lineup, :shift => 2)
      end
=end
      after(:create) do |lineup, evaluator|
        create(:scheduling_with_restaurant, :daily_lineup => lineup, :shift => 1, :position => 1)
        create(:scheduling_with_restaurant, :daily_lineup => lineup, :shift => 1, :position => 2)
        create(:scheduling_with_restaurant, :daily_lineup => lineup, :shift => 1, :position => 3)
        create(:scheduling_with_restaurant, :daily_lineup => lineup, :shift => 2, :position => 1)
        create(:scheduling_with_restaurant, :daily_lineup => lineup, :shift => 2, :position => 2)
        create(:scheduling_with_restaurant, :daily_lineup => lineup, :shift => 2, :position => 3)
      end
    end
  end

  factory :course do
    sequence(:name) {|seq| "Course#{seq}"}

    factory :course_with_restaurant do
        restaurant
    end
  end

  factory :dish do
    sequence(:name) {|seq| "Dish#{seq}"}

    factory :dish_with_course do
      association :course, factory: :course_with_restaurant
    end
  end

  factory :rating do
    value 3

    factory :restaurant_rating do

    end
  end

end
