require "application_system_test_case"

class RegistrationFlowTest < ApplicationSystemTestCase
  test "user signs up in two steps" do
    visit new_session_path

    click_on "Criar conta"

    fill_in "Nome completo", with: "Pessoa Teste"
    fill_in "E-mail", with: "pessoa@example.com"
    fill_in "Senha", with: "password"
    fill_in "Confirmar senha", with: "password"
    click_on "Continuar"

    assert_text "Como você aprende?"

    choose "Tenho os dois"

    assert_button "Começar", disabled: false
    click_on "Começar"

    assert_current_path root_path
    assert_text "Bem-vindo ao Focus"
  end
end
