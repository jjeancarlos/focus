class CreateTentativas < ActiveRecord::Migration[8.1]
  def change
    create_table :tentativas do |t|
      t.bigint  :aluno_id,       null: false
      t.string  :tipo_missao,    null: false
      t.integer :pontuacao,      null: false, default: 0
      t.integer :tempo_gasto,    null: false, default: 0
      t.integer :xp_ganho,       null: false, default: 0
      t.datetime :concluida_em,  null: false

      t.timestamps
    end

    add_index :tentativas, :aluno_id
    add_index :tentativas, :tipo_missao
    add_index :tentativas, :concluida_em
    add_foreign_key :tentativas, :users, column: :aluno_id
  end
end
