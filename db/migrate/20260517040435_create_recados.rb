class CreateRecados < ActiveRecord::Migration[8.1]
  def change
    create_table :recados do |t|
      t.text :mensagem
      t.integer :professor_id
      t.integer :turma_id

      t.timestamps
    end
  end
end
