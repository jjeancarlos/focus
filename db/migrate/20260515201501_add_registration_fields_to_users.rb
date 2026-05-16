class AddRegistrationFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string, null: false, default: ""
    add_column :users, :role, :string, null: false, default: "aluno"
    add_column :users, :perfil_acessibilidade, :string
    add_column :users, :xp_total, :integer, null: false, default: 0
    add_column :users, :nivel, :integer, null: false, default: 1
    add_column :users, :sequencia_dias, :integer, null: false, default: 0
    add_reference :users, :turma, foreign_key: true
  end
end
