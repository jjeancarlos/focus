Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  get "cadastro"          => "registrations#new",          as: :cadastro
  post "cadastro"         => "registrations#create"
  get "cadastro/perfil"   => "registrations#perfil",       as: :cadastro_perfil
  patch "cadastro/perfil" => "registrations#update_perfil"

  get "aluno/dashboard", to: "aluno/dashboard#show", as: :aluno_dashboard

  get "missoes", to: "missoes#index", as: :missoes
  get "missoes/:tipo", to: "missoes#show", as: :missao
  post "missoes/:tipo/responder", to: "missoes#responder", as: :responder_missao
  get "missoes/:tipo/resultado/:tentativa_id", to: "missoes#resultado", as: :resultado_missao

  get "conquistas",  to: "conquistas#index",  as: :conquistas
  get "perfil",      to: "perfil#show",       as: :perfil

  root "home#index"

  get "up" => "rails/health#show", as: :rails_health_check
end