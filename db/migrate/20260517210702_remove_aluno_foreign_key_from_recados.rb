class RemoveAlunoForeignKeyFromRecados < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :recados, column: :aluno_id
  end
end
