require "application_system_test_case"

class MissoesFlowTest < ApplicationSystemTestCase
  test "student completes reading mission" do
    atividade = atividades(:leitura)
    visit new_session_path

    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Entrar"

    visit aluno_dashboard_path
    click_on "Iniciar uma Missão"
    click_on "Leitura Guiada"

    assert_text atividade.titulo
    choose("respostas[leitura_1]", option: "0")
    choose("respostas[leitura_2]", option: "1")
    click_on "Concluir missão"

    assert_text "+"
    assert_text "Fazer outra missão"
    assert_text "Ver meu progresso"
  end
end
