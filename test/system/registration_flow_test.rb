require "application_system_test_case"
require "securerandom"

class RegistrationFlowTest < ApplicationSystemTestCase
  test "user signs up and lands on class code step" do
    email = "pessoa-#{SecureRandom.hex(4)}@example.com"

    visit new_session_path

    click_on "Criar conta"

    fill_in "Nome completo", with: "Pessoa Teste"
    fill_in "E-mail", with: email
    fill_in "Senha", with: "password"
    fill_in "Confirmar senha", with: "password"
    click_on "Continuar"

    assert_text "Como você aprende?"
    assert_selector "#start-button-container.hidden", visible: false
    assert_button "Começar", disabled: true, visible: false

    find("label[for='user_perfil_acessibilidade_ambos']").click

    assert_no_selector "#start-button-container.hidden", visible: false
    assert_button "Começar", disabled: false
    click_on "Começar"

    assert_current_path cadastro_turma_path
    assert_text "Você tem um código de turma?"
  ensure
    User.find_by(email_address: email)&.destroy!
  end
end
