require "test_helper"

class MissoesControllerTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup do
    @aluno = users(:one)
    @professor = users(:two)
    @atividade = atividades(:leitura)
  end

  test "requires authentication" do
    get missoes_path

    assert_redirected_to new_session_path(return_to: missoes_path)
  end

  test "allows aluno to access missions index" do
    sign_in_as(@aluno)

    get missoes_path

    assert_response :success
    assert_select "h1", "Escolha sua Missão"
  end

  test "blocks professor from missions" do
    sign_in_as(@professor)

    get missoes_path

    assert_redirected_to root_path
  end

  test "show starts current mission session" do
    sign_in_as(@aluno)

    get missao_path(@atividade.tipo)

    assert_response :success
    assert_equal @atividade.id, session[:missao_atual]["atividade_id"]
  end

  test "responder creates tentativa and redirects to result" do
    sign_in_as(@aluno)
    get missao_path(@atividade.tipo)

    assert_difference("Tentativa.count", 1) do
      post responder_missao_path(@atividade.tipo), params: {
        respostas: {
          "leitura_1" => "0",
          "leitura_2" => "1"
        }
      }
    end

    tentativa = Tentativa.order(:id).last
    assert_redirected_to resultado_missao_path(@atividade.tipo, tentativa_id: tentativa.id)
  end

  test "resultado only opens own tentativa" do
    sign_in_as(@aluno)
    tentativa = @aluno.tentativas.create!(atividade: @atividade, tipo_missao: @atividade.tipo, pontuacao: 1, tempo_gasto: 10, xp_ganho: 20, concluida_em: Time.current)

    get resultado_missao_path(@atividade.tipo, tentativa_id: tentativa.id)

    assert_response :success
    assert_select "h1", text: /\+20 XP/
  end
end
