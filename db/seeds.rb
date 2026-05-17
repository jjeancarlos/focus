# ============================================================
# PROFESSOR FIXO — login: professor@focus.com / senha: focus123
# ============================================================
professor = User.find_or_initialize_by(email_address: "professor@focus.com")
professor.name                  = "Prof. Ana Silva"
professor.password              = "focus123"
professor.password_confirmation = "focus123"
professor.role                  = "professor"
professor.perfil_acessibilidade = nil
professor.save!

puts "Professor criado: professor@focus.com / focus123"

# ============================================================
# TURMA PADRÃO
# ============================================================
turma = Turma.find_or_initialize_by(nome: "Turma Focus")
turma.professor_id  = professor.id
turma.invite_token  = "FOCUS2026"
turma.save!

puts "Turma criada: #{turma.nome}"

# ============================================================
# ALUNO DE DEMONSTRAÇÃO
# ============================================================
aluno = User.find_or_initialize_by(email_address: "aluno@focus.com")
aluno.name                  = "João Silva"
aluno.password              = "focus123"
aluno.password_confirmation = "focus123"
aluno.role                  = "aluno"
aluno.perfil_acessibilidade = "dislexia"
aluno.turma                 = turma
aluno.xp_total              = 124
aluno.nivel                 = 2
aluno.sequencia_dias        = 3
aluno.save!

puts " Alno criado: aluno@focus.com / focus123"

# ============================================================
# ATIVIDADES — LEITURA
# ============================================================
Atividade.find_or_initialize_by(titulo: "Leitura no parque").tap do |atividade|
  atividade.tipo = "leitura"
  atividade.descricao = "Treino de leitura com foco em compreensão"
  atividade.conteudo = "Lia foi ao parque com sua avó em uma manhã tranquila. Elas levaram frutas, água e um livro para ler debaixo da árvore maior. Depois da leitura, Lia viu duas crianças brincando de bola e decidiu participar por alguns minutos antes de voltar para casa."
  atividade.perguntas = [
    {
      "id" => "leitura_1",
      "enunciado" => "Com quem Lia foi ao parque?",
      "opcoes" => ["Com a professora", "Com a avó", "Com a irmã"],
      "correta_index" => 1
    },
    {
      "id" => "leitura_2",
      "enunciado" => "O que Lia fez depois da leitura?",
      "opcoes" => ["Foi embora imediatamente", "Comeu sozinha", "Brincou de bola por alguns minutos"],
      "correta_index" => 2
    }
  ]
  atividade.xp_base = 30
  atividade.ativo = true
  atividade.save!
end

puts "Atividade de leitura criada"

# ============================================================
# ATIVIDADES — FOCO
# ============================================================
[
  {
    titulo: "Foco na sala de aula",
    imagem_url: "sala_aula.jpeg",
    opcoes: ["Planta", "Relógio", "Computador", "Livro"],
    correta_index: 2
  },
  {
    titulo: "Foco na cozinha",
    imagem_url: "cozinha.jpeg",
    opcoes: ["Televisão", "Geladeira", "Panela", "Xícara"],
    correta_index: 0
  },
  {
    titulo: "Foco no quarto",
    imagem_url: "quarto.jpeg",
    opcoes: ["Cama", "Fogão", "Abajur", "Guarda-roupa"],
    correta_index: 1
  },
  {
    titulo: "Foco no parque",
    imagem_url: "parque.jpeg",
    opcoes: ["Banco", "Árvore", "Poste de luz", "Carro"],
    correta_index: 3
  }
].each_with_index do |dados, index|
  Atividade.find_or_initialize_by(titulo: dados[:titulo]).tap do |atividade|
    atividade.tipo = "foco"
    atividade.descricao = "Observação e memória visual"
    atividade.imagem_url = dados[:imagem_url]
    atividade.perguntas = [
      {
        "id" => "foco_#{index + 1}",
        "tempo_exibicao" => 10,
        "enunciado" => "Qual destes itens não aparecia na imagem?",
        "opcoes" => dados[:opcoes],
        "correta_index" => dados[:correta_index]
      }
    ]
    atividade.xp_base = 40
    atividade.ativo = true
    atividade.save!
  end
end

puts "Atividades de foco criadas"

# ============================================================
# ATIVIDADES — DESAFIO
# ============================================================
Atividade.find_or_initialize_by(titulo: "Monte a frase").tap do |atividade|
  atividade.tipo = "desafio"
  atividade.descricao = "Sequência de palavras com imagens"
  atividade.conteudo = "Organize as palavras na ordem correta."
  atividade.perguntas = [
    {
      "id" => "desafio_1",
      "tempo_ideal" => 30,
      "enunciado" => "Monte a frase corretamente",
      "palavras" => ["Eu", "gosto", "de", "ler"],
      "ordem_correta" => ["Eu", "gosto", "de", "ler"]
    }
  ]
  atividade.xp_base = 50
  atividade.ativo = true
  atividade.save!
end

puts "Atividade de desafio criada"
puts ""
puts " Seeds concluídos!"
puts "   Professor: professor@focus.com / focus123"
puts "   Aluno:     aluno@focus.com / focus123"