class CreateTurmas < ActiveRecord::Migration[8.1]
  def change
    create_table :turmas do |t|
      t.string :nome
      t.string :invite_token
      t.integer :professor_id

      t.timestamps
    end
  end
end
