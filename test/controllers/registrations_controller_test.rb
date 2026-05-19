require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup { @existing_user = users(:one) }

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
    assert_select "div", /Quase lá! Revise os campos para continuar\./
  end

  test "create with short password rerenders form" do
    assert_no_difference("User.count") do
      post cadastro_path, params: {
        user: {
          name: "Nova Pessoa",
          email_address: "curta@example.com",
          password: "1234567",
          password_confirmation: "1234567"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "li", /Senha deve ter pelo menos 8 caracteres/
  end

  test "create with duplicated email shows login link" do
    assert_no_difference("User.count") do
      post cadastro_path, params: {
        user: {
          name: "Pessoa Duplicada",
          email_address: @existing_user.email_address.upcase,
          password: "password",
          password_confirmation: "password"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "a[href='#{new_session_path}']", /fazer login/
    assert_select "li", /Esse email já está cadastrado\./
  end

  test "perfil redirects when no pending user exists" do
    get cadastro_perfil_path

    assert_redirected_to cadastro_path
  end

  test "update perfil completes onboarding and redirects to class code step" do
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

    assert_redirected_to cadastro_turma_path
    assert_nil cookies[:session_id]
    assert_equal "ambos", user.reload.perfil_acessibilidade
  end

  test "update perfil ignores stale return path and goes to class code step" do
    post cadastro_path, params: {
      user: {
        name: "Nova Pessoa",
        email_address: "stale@example.com",
        password: "password",
        password_confirmation: "password"
      }
    }

    patch cadastro_perfil_path, params: { user: { perfil_acessibilidade: "tdh" }, return_to: "/missoes" }

    assert_redirected_to cadastro_turma_path
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
    assert_select "div", /Quase lá! Escolha o perfil que combina com você\./
  end

  test "entrar turma redirects aluno to missoes" do
    post cadastro_path, params: {
      user: {
        name: "Com Turma",
        email_address: "comturma@example.com",
        password: "password",
        password_confirmation: "password"
      }
    }

    post cadastro_turma_path, params: { invite_token: turmas(:one).invite_token }

    assert_redirected_to missoes_path
    assert cookies[:session_id]
    assert_equal turmas(:one).id, User.find_by!(email_address: "comturma@example.com").turma_id
  end

  test "pular turma redirects aluno to missoes" do
    post cadastro_path, params: {
      user: {
        name: "Sem Turma",
        email_address: "semturma@example.com",
        password: "password",
        password_confirmation: "password"
      }
    }

    post cadastro_pular_path

    assert_redirected_to missoes_path
    assert cookies[:session_id]
    assert_nil User.find_by!(email_address: "semturma@example.com").turma_id
  end
end
