require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    OmniAuth.config.test_mode = true
  end

  teardown do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth.delete(:google_oauth2)
  end

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

  test "root redirects authenticated professor to dashboard" do
    sign_in_as(users(:two))
    get root_path
    assert_redirected_to professor_dashboard_path
  end

  test "root redirects authenticated aluno to missoes" do
    sign_in_as(users(:one))
    get root_path
    assert_redirected_to missoes_path
  end

  test "google callback creates new aluno and redirects to onboarding" do
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: "google_oauth2",
      uid: "123456789",
      info: { email: "novo@gmail.com", name: "Aluno Novo" }
    })
    post "/auth/google_oauth2/callback"
    assert_redirected_to perfil_registration_path
    user = User.find_by(email_address: "novo@gmail.com")
    assert_not_nil user
    assert_equal "aluno", user.role
    assert_equal "google_oauth2", user.provider
  end

  test "google callback logs in existing aluno and links account" do
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: "google_oauth2",
      uid: "999",
      info: { email: users(:one).email_address, name: users(:one).name }
    })
    post "/auth/google_oauth2/callback"
    assert_redirected_to missoes_path
    users(:one).reload
    assert_equal "google_oauth2", users(:one).provider
  end

  test "google callback blocks professor" do
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new({
      provider: "google_oauth2",
      uid: "888",
      info: { email: users(:two).email_address, name: users(:two).name }
    })
    post "/auth/google_oauth2/callback"
    assert_redirected_to new_session_path
  end
end