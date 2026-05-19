require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid aluno credentials" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to missoes_path
    assert cookies[:session_id]
  end

  test "create with valid professor credentials redirects to dashboard" do
    professor = users(:two)

    post session_path, params: { email_address: professor.email_address, password: "password" }

    assert_redirected_to professor_dashboard_path
    assert cookies[:session_id]
  end

  test "create with valid credentials redirects to safe return path" do
    post session_path, params: { email_address: @user.email_address, password: "password", return_to: "/missoes" }

    assert_redirected_to missoes_path
    assert cookies[:session_id]
  end

  test "create with valid credentials ignores unsafe return path" do
    post session_path, params: { email_address: @user.email_address, password: "password", return_to: "https://evil.example.com" }

    assert_redirected_to missoes_path
    assert cookies[:session_id]
  end

  test "create with unknown email" do
    post session_path, params: { email_address: "missing@example.com", password: "password" }

    assert_redirected_to new_session_path(email_address: "missing@example.com")
    assert_nil cookies[:session_id]

    follow_redirect!
    assert_select "div", /Não encontramos uma conta com esse email\./
  end

  test "create with wrong password" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path(email_address: @user.email_address)
    assert_nil cookies[:session_id]

    follow_redirect!
    assert_select "div", /Senha incorreta\. Tente novamente\./
  end

  test "destroy" do
    sign_in_as(users(:one))

    delete session_path

    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end
end
