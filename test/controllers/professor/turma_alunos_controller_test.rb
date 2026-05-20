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

  test "returns json error for xhr relatório request failure" do
    singleton = StudentReportDataService.singleton_class
    original_new = StudentReportDataService.method(:new)

    singleton.define_method(:new) do |*_args|
      raise StandardError, "boom"
    end

    get relatorio_ia_professor_turma_aluno_path(@turma, @aluno), headers: {
      "X-Requested-With" => "XMLHttpRequest",
      "Accept" => "application/pdf"
    }

    assert_response :unprocessable_entity
    assert_equal "application/json", response.media_type
    assert_equal({ "error" => "Erro ao gerar o relatório." }, JSON.parse(response.body))
  ensure
    singleton.define_method(:new) do |*args, **kwargs, &block|
      original_new.call(*args, **kwargs, &block)
    end
  end
end
