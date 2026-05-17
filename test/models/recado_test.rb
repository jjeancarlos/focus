require "test_helper"

class RecadoTest < ActiveSupport::TestCase
  test "is valid with turma target" do
    recado = Recado.new(mensagem: "Bom trabalho", professor: users(:two), turma: turmas(:one))

    assert recado.valid?
  end

  test "is valid with aluno target" do
    recado = Recado.new(mensagem: "Continue assim", professor: users(:two), aluno_id: users(:one).id)

    assert recado.valid?
  end

  test "requires one target" do
    recado = Recado.new(mensagem: "Sem destino", professor: users(:two))

    assert_not recado.valid?
    assert_includes recado.errors[:base], "Escolha uma turma ou um aluno para enviar o recado."
  end

  test "does not allow turma and aluno together" do
    recado = Recado.new(mensagem: "Duplicado", professor: users(:two), turma: turmas(:one), aluno_id: users(:one).id)

    assert_not recado.valid?
    assert_includes recado.errors[:base], "Escolha apenas um destino para o recado."
  end
end
