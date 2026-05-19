require "test_helper"

class Aluno::DashboardControllerTest < ActionDispatch::IntegrationTest
  include SessionTestHelper

  test "shows dashboard for aluno" do
    sign_in_as(users(:one))

    get aluno_dashboard_path

    assert_response :success
  end

  test "redirects professor away from aluno dashboard" do
    sign_in_as(users(:two))

    get aluno_dashboard_path

    assert_redirected_to root_path
  end
end
