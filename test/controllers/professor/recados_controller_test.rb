require "test_helper"

class Professor::RecadosControllerTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup do
    sign_in_as(users(:two))
  end

  test "creates turma recado" do
    assert_difference("Recado.count", 1) do
      post professor_recados_path, params: {
        recado: {
          mensagem: "Bom trabalho, turma!",
          turma_id: turmas(:one).id
        }
      }
    end

    recado = Recado.order(:id).last
    assert_redirected_to professor_turma_path(turmas(:one))
    assert_equal turmas(:one).id, recado.turma_id
    assert_nil recado.aluno_id
  end

  test "creates individual recado" do
    assert_difference("Recado.count", 1) do
      post professor_recados_path, params: {
        recado: {
          mensagem: "Você está indo bem!",
          aluno_id: users(:one).id
        }
      }
    end

    recado = Recado.order(:id).last
    assert_redirected_to professor_turma_aluno_path(turmas(:one), users(:one))
    assert_equal users(:one).id, recado.aluno_id
    assert_nil recado.turma_id
  end

  test "does not create recado with blank mensagem" do
    assert_no_difference("Recado.count") do
      post professor_recados_path, params: {
        recado: {
          mensagem: "   ",
          turma_id: turmas(:one).id
        }
      }
    end

    assert_redirected_to professor_turma_path(turmas(:one))
  end
end
