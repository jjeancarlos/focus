require "application_system_test_case"

class MissoesFlowTest < ApplicationSystemTestCase
  test "student completes reading mission" do
    atividade = atividades(:leitura)
    visit new_session_path

    fill_in "email_address", with: users(:one).email_address
    fill_in "password", with: "password"
    click_on "Entrar"

    visit missoes_path
    click_on "Leitura Guiada"

    assert_text atividade.titulo
    find("label", text: "Um livro azul").click
    find("label", text: "Na escola").click

    assert_text "+"
    assert_text "Fazer outra missão"
    assert_text "Ver meu progresso"
  end
end
