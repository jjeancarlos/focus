Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token

  get   "cadastro"         => "registrations#new",          as: :cadastro
  post  "cadastro"         => "registrations#create"
  get   "cadastro/perfil"  => "registrations#perfil",       as: :cadastro_perfil
  patch "cadastro/perfil"  => "registrations#update_perfil"
  get   "cadastro/turma"   => "registrations#codigo_turma", as: :cadastro_turma
  post  "cadastro/turma"   => "registrations#entrar_turma"
  post  "cadastro/pular"   => "registrations#pular_turma",  as: :cadastro_pular

  get   "aluno/dashboard",  to: "aluno/dashboard#show",     as: :aluno_dashboard
  get   "missoes",          to: "missoes#index",            as: :missoes
  get   "missoes/:tipo",    to: "missoes#show",             as: :missao
  post  "missoes/:tipo/responder", to: "missoes#responder", as: :responder_missao
  get   "missoes/:tipo/resultado/:tentativa_id",
        to: "missoes#resultado",                            as: :resultado_missao

  get   "conquistas",       to: "conquistas#index",         as: :conquistas
  get   "perfil",           to: "perfil#show",              as: :perfil
  patch "perfil",           to: "perfil#update"
  patch "perfil/turma",     to: "perfil#update_turma",      as: :perfil_turma

  get  "notificacoes", to: "notificacoes#index",    as: :notificacoes
  get  "notificacoes/contagem", to: "notificacoes#contagem", as: :notificacoes_contagem

  namespace :professor do
    get "dashboard",        to: "dashboard#show",           as: :dashboard
    resources :turmas, only: %i[show new create destroy] do
      resources :alunos, only: %i[show destroy], controller: "turma_alunos"
    end
    resources :recados, only: :create
  end

  root "home#index"
  get "up" => "rails/health#show", as: :rails_health_check
end