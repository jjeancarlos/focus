class CreateAtividades < ActiveRecord::Migration[8.1]
  def change
    create_table :atividades do |t|
      t.string :tipo, null: false
      t.string :titulo, null: false
      t.text :descricao, null: false
      t.text :conteudo
      t.string :imagem_url
      t.jsonb :perguntas, null: false, default: []
      t.integer :xp_base, null: false, default: 20
      t.boolean :ativo, null: false, default: true

      t.timestamps
    end

    add_index :atividades, :tipo
    add_index :atividades, :ativo
    add_reference :tentativas, :atividade, foreign_key: true, null: true
  end
end
