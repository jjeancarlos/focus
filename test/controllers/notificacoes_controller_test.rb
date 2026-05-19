require "test_helper"

class NotificacoesControllerTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup do
    @aluno = users(:one)
    @professor = users(:two)
    sign_in_as(@aluno)
  end

  test "shows turma and individual recados for aluno" do
    get notificacoes_path

    assert_response :success
    assert_match "Recado da turma", response.body
    assert_match "Recado individual", response.body
  end

  test "does not show another student's individual recado" do
    get notificacoes_path

    assert_response :success
    assert_no_match "Recado para outro aluno", response.body
  end

  test "redirects professor away from notificacoes" do
    sign_in_as(@professor)

    get notificacoes_path

    assert_redirected_to root_path
  end
end
