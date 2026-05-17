Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  get  "cadastro"              => "registrations#new",           as: :cadastro
  post "cadastro"              => "registrations#create"
  get  "cadastro/perfil"       => "registrations#perfil",        as: :cadastro_perfil
  patch "cadastro/perfil"      => "registrations#update_perfil"
  get  "cadastro/turma"        => "registrations#codigo_turma",  as: :cadastro_turma
  post "cadastro/turma"        => "registrations#entrar_turma"

  get  "aluno/dashboard",      to: "aluno/dashboard#show",       as: :aluno_dashboard
  get  "missoes",              to: "missoes#index",              as: :missoes
  get  "missoes/:tipo",        to: "missoes#show",               as: :missao
  post "missoes/:tipo/responder", to: "missoes#responder",       as: :responder_missao
  get  "missoes/:tipo/resultado/:tentativa_id",
       to: "missoes#resultado",                                  as: :resultado_missao
  get  "conquistas",           to: "conquistas#index",           as: :conquistas
  get  "perfil",               to: "perfil#show",                as: :perfil
  patch "perfil",              to: "perfil#update"

  namespace :professor do
    get  "dashboard",          to: "dashboard#show",             as: :dashboard
    resources :turmas, only: %i[show] do
      resources :alunos, only: %i[show], controller: "turma_alunos"
    end
    resources :recados, only: :create
  end

  root "home#index"
  get "up" => "rails/health#show", as: :rails_health_check
end