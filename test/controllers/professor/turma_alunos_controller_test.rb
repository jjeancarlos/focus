require "test_helper"

class Professor::TurmaAlunosControllerTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup do
    @professor = users(:two)
    @turma = turmas(:one)
    @aluno = users(:one)
    sign_in_as(@professor)
  end

  test "shows aluno profile" do
    get professor_turma_aluno_path(@turma, @aluno)

    assert_response :success
    assert_select "h1", /#{Regexp.escape(@aluno.name)}/
  end

  test "removes aluno from turma without deleting account" do
    assert_no_difference("User.count") do
      delete professor_turma_aluno_path(@turma, @aluno)
    end

    assert_redirected_to professor_turma_path(@turma)
    assert_equal "Aluno removido da turma com sucesso.", flash[:notice]
    assert_nil @aluno.reload.turma_id
  end
end
