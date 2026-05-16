Rails.application.routes.draw do
  root "home#index"

  resource :session
  resources :passwords, param: :token

  get "cadastro" => "registrations#new", as: :cadastro
  post "cadastro" => "registrations#create"
  get "cadastro/perfil" => "registrations#perfil", as: :cadastro_perfil
  patch "cadastro/perfil" => "registrations#update_perfil"

  get "up" => "rails/health#show", as: :rails_health_check
end
