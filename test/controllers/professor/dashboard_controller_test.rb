require "test_helper"

class Professor::DashboardControllerTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  setup do
    @professor = users(:two)
    sign_in_as(@professor)
  end

  test "shows dashboard" do
    get professor_dashboard_path

    assert_response :success
    assert_select "h1", /Olá/
    assert_select "p", /Painel do professor/
    assert_select "p", /Turma A/
    assert_select "p", /Turma B/
  end

  test "filters turmas by turma name" do
    get professor_dashboard_path, params: { q: "Turma A" }

    assert_response :success
    assert_select "p", /Turma A/
    assert_select "p", text: /Turma B/, count: 0
  end

  test "filters turmas by aluno name" do
    get professor_dashboard_path, params: { q: "Aluna Um" }

    assert_response :success
    assert_select "p", /Turma A/
    assert_select "p", text: /Turma B/, count: 0
  end

  test "shows empty state for unmatched search" do
    get professor_dashboard_path, params: { q: "Sem resultado" }

    assert_response :success
    assert_select "p", /Nenhuma turma ou aluno encontrado/
  end
end
