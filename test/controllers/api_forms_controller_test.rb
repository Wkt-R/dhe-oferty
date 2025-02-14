require "test_helper"

class ApiFormsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_forms_index_url
    assert_response :success
  end

  test "should get edit" do
    get api_forms_edit_url
    assert_response :success
  end

  test "should get update" do
    get api_forms_update_url
    assert_response :success
  end
end
