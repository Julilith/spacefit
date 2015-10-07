Rails.application.routes.draw do
  #—————user routes
  resources :users, except: [:new, :create] do
    member do
      put  :update_password
      put  :update_email
    end
  end
  match '/recover_password/:token',
                          to: 'users#recover_password', via: 'get', as:  'reset_password'

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
  match '/onmyway'    ,     to: 'sessions#redirect',      via: 'get' #FIXME what is this one for?
  match '/signout'    ,     to: 'sessions#destroy',       via: 'delete'

end
