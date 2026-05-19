require "test_helper"

class Professor::TurmasControllerTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup do
    @professor = users(:two)
    @turma = turmas(:one)
    @aluno = users(:one)
    sign_in_as(@professor)
  end

  test "destroys turma and unassigns students" do
    assert_difference("Turma.count", -1) do
      delete professor_turma_path(@turma)
    end

    assert_redirected_to professor_dashboard_path
    assert_equal "Turma excluída e alunos desvinculados com sucesso.", flash[:notice]
    assert_nil @aluno.reload.turma_id
    assert User.exists?(@aluno.id)
  end
end
