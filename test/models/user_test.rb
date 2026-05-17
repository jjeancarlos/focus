require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "requires name" do
    user = User.new(email_address: "name@example.com", password: "password", password_confirmation: "password")

    assert_not user.valid?
    assert_includes user.errors[:name], "não pode ficar em branco"
  end

  test "requires valid role" do
    user = User.new(name: "Nome", email_address: "role@example.com", password: "password", password_confirmation: "password", role: "admin")

    assert_not user.valid?
    assert_includes user.errors[:role], "não está incluído na lista"
  end

  test "requires password with at least 8 characters" do
    user = User.new(name: "Nome", email_address: "short@example.com", password: "1234567", password_confirmation: "1234567", role: "aluno")

    assert_not user.valid?
    assert_includes user.errors[:password], "deve ter pelo menos 8 caracteres"
  end

  test "requires valid accessibility profile when completing onboarding" do
    user = User.new(name: "Nome", email_address: "perfil@example.com", password: "password", password_confirmation: "password", role: "aluno")
    user.require_profile_completion = true

    assert_not user.valid?
    assert_includes user.errors[:perfil_acessibilidade], "não pode ficar em branco"
  end

  test "accepts valid accessibility profile" do
    user = User.new(name: "Nome", email_address: "ok@example.com", password: "password", password_confirmation: "password", role: "aluno", perfil_acessibilidade: "ambos")
    user.require_profile_completion = true

    assert user.valid?
  end
end
