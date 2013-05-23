Lunchy::Application.routes.draw do

# config/routes.rb
  resources :password_resets, :only => [:new, :create, :edit, :update]

  get "logout" => "sessions#destroy", :as => "logout"
  get "login" =>"sessions#new", :as => "login"
  get "signup" => "users#new", :as => "signup"

  resources :users, :only => [:new, :create, :edit, :update] do
    member do
      get :activate
    end
  end

  resources :sessions, :only => [:new, :create, :destroy]

  get "lineups/:id" => "daily_lineups#show", :as => "lineups", :constraints => {:id => /[0-9]+|today/}

  constraints(:id => /[0-9]+/) do
    resources :restaurants do
      #resources :dishes, :only => [:index]
      #get "dishes" => "dishes#index_for_restaurant", :on => :member, :as => "dishes_for"
      resources :courses, :only => :index
      resources :dishes, :only => :index
      resources :reviews, :only => [:index, :new, :create]
      post "rate" => "restaurants#rate"
    end

    resources :courses, :only => [:show, :update, :edit, :destroy] do
      resources :dishes, :only => :index
    end

    resources :dishes, :only => [:show, :update, :edit, :destroy] do
      resources :reviews, :only => [:index, :new, :create]
      post "rate" => "dishes#rate"
    end

    # when manipulating an existing review, only have route
    # for that review instead of nesting for irrelevant
    # reviewable objects (restaurant/dish)
    resources :reviews, :only => [:show, :update, :edit, :destroy]
    get "reviews" => "reviews#index_all"
  end


  #get "home/index"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'daily_lineups#show', :defaults => { :id => "today" }

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
