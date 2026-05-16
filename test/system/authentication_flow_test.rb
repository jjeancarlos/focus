require "application_system_test_case"

class AuthenticationFlowTest < ApplicationSystemTestCase
  test "shows specific message for unknown email" do
    visit new_session_path

    fill_in "E-mail", with: "naoexiste@example.com"
    fill_in "Senha", with: "password"
    click_on "Entrar"

    assert_current_path(/\/session\/new/)
    assert_text "Não encontramos uma conta com esse email."
  end

  test "shows specific message for wrong password" do
    visit new_session_path

    fill_in "E-mail", with: users(:one).email_address
    fill_in "Senha", with: "senha-errada"
    click_on "Entrar"

    assert_current_path(/\/session\/new/)
    assert_text "Senha incorreta. Tente novamente."
  end

  test "shows login link for duplicated email" do
    visit cadastro_path

    fill_in "Nome completo", with: "Pessoa Duplicada"
    fill_in "E-mail", with: users(:one).email_address.upcase
    fill_in "Senha", with: "password"
    fill_in "Confirmar senha", with: "password"
    click_on "Continuar"

    assert_current_path cadastro_path
    assert_text "Esse email já está cadastrado."
    click_on "fazer login"

    assert_current_path new_session_path
  end

  test "returns to protected page after successful login" do
    visit missoes_path

    assert_current_path(/\/session\/new/)

    fill_in "E-mail", with: users(:one).email_address
    fill_in "Senha", with: "password"
    click_on "Entrar"

    assert_current_path missoes_path
  end
end
