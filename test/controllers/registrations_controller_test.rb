require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get cadastro_path
    assert_response :success
  end

  test "create with valid params redirects to profile step" do
    assert_difference("User.count", 1) do
      post cadastro_path, params: {
        user: {
          name: "Nova Pessoa",
          email_address: "nova@example.com",
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_redirected_to cadastro_perfil_path
    assert_equal User.order(:id).last.id, session[:pending_registration_user_id]
  end

  test "create with invalid params rerenders form" do
    assert_no_difference("User.count") do
      post cadastro_path, params: {
        user: {
          name: "",
          email_address: "",
          password: "password",
          password_confirmation: "different"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "perfil redirects when no pending user exists" do
    get cadastro_perfil_path

    assert_redirected_to cadastro_path
  end

  test "update perfil completes onboarding and signs in user" do
    post cadastro_path, params: {
      user: {
        name: "Nova Pessoa",
        email_address: "outra@example.com",
        password: "password",
        password_confirmation: "password"
      }
    }

    user = User.find_by!(email_address: "outra@example.com")

    patch cadastro_perfil_path, params: { user: { perfil_acessibilidade: "ambos" } }

    assert_redirected_to root_path
    assert cookies[:session_id]
    assert_equal "ambos", user.reload.perfil_acessibilidade
  end

  test "update perfil with invalid params rerenders step" do
    post cadastro_path, params: {
      user: {
        name: "Nova Pessoa",
        email_address: "semperfil@example.com",
        password: "password",
        password_confirmation: "password"
      }
    }

    user = User.find_by!(email_address: "semperfil@example.com")

    patch cadastro_perfil_path, params: { user: { perfil_acessibilidade: "" } }

    assert_response :unprocessable_entity
    assert_nil user.reload.perfil_acessibilidade
  end
end
