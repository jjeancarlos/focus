class AddAlunoIdToRecados < ActiveRecord::Migration[8.1]
  def change
    add_column :recados, :aluno_id, :integer
    add_index :recados, :aluno_id
    add_foreign_key :recados, :users, column: :aluno_id
  end
end
