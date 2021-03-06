Rails.application.routes.draw do
  root 'static_pages#home'
  match "/home",  to: "static_pages#home" , via: "get"
  match "/about", to: "static_pages#about", via: "get"
  #—————feedback
  resources :feedbacks, only: [:new, :create]

  #—————workout
  match "/workout_type"    , to: "workouts#type"    , via: "get", as: "workout_type"
  match "/workout_location", to: "workouts#location", via: "get", as: "workout_location"
  match "/workout_position", to: "workouts#position", via: "get", as: "workout_position"

  match "/workout_show",     to: "workouts#show", via: "get", as: "workout_show"
  match "/workout_reload",   to: "workouts#reload", via: "post", as: "workout_reload"
  match "/workout_completed",to: "workouts#completed", via: "get", as: "workout_completed"

  #—————user routes
  match "/users/chart",  to: "users#progress", via: "get",   as: "progress_user"
  match "/users/update", to: "users#update",   via: "post" , as: "update_user" 
  match "/users/disclaimer", to: "users#disclaimer",   via: "post" , as: "post_disclaimer_user" 
  match "/users/edit",   to: "users#edit",     via: "get" ,  as: "edit_user" 
  match "/users/like_media",   to: "users#like_media",     via: "post" ,  as: "like_media_user" 
  resources :users, except: [:index, :edit] do
    member do
      put  :update_password
      put  :update_email
    end
  end

  match '/recover_password/:token',
                          to: 'users#recover_password', via: 'get', as:  'reset_password'
  
  match '/rateapp',       to: 'users#rateapp'         , via: 'post', as: "rateapp"

  #—————Sign's ups
  match '/signup_form'   ,to: 'sign_ups#request_new',   via: 'get', as: "signup_form"
  match '/signup/(:with)',to: 'sign_ups#new',           via: 'get', as: "signup"
  match '/signup',        to: 'sign_ups#create',        via: 'post'
  match '/confirm_email/:token',
                          to: 'sign_ups#confirm_email', via: 'get', as: "confirm_email"
  match 'auth/:provider', to: 'sign_ups#new',           via: [:get, :post],
                                                                    as: "auth"
  match 'auth/facebook/callback',
                          to: 'sign_ups#facebook',
                                                        via: [:get, :post]
  match 'auth/failure',   to: 'static_pages#home',      via: [:get, :post]

  #—————tokens routes
  match '/recover_password'    , to:  'tokens#recover_password'    , via: 'get'
  match '/recover_password_new', to:  'tokens#recover_password_new',
                                 via: 'get',
                                 as:  'recover_password_new'
  match '/user/change_email',
                          to: 'tokens#change_email', via: 'get', as:  'change_email'

  #—————Session routes
  resources :sessions ,     only:[:create]
  match '/signin'     ,     to: 'sessions#new',           via: 'get'
  match '/signin'     ,     to: 'sessions#create',        via: 'post'
  match '/onmyway'    ,     to: 'sessions#redirect',      via: 'get' #FIXME what is this one for?
  match '/signout'    ,     to: 'sessions#destroy',       via: 'delete'

end
