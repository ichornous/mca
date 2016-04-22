require 'test_helper'

class VisitsControllerTest < ActionController::TestCase
  setup do
    visit = events(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:visits)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create event" do
    assert_difference('Event.count') do
      post :create, visit: {description: visit.description, end: visit.end, start: visit.start, title: visit.title }
    end

    assert_redirected_to event_path(assigns(:visit))
  end

  test "should show event" do
    get :show, id: visit
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: visit
    assert_response :success
  end

  test "should update event" do
    patch :update, id: visit, visit: {description: visit.description, end: visit.end, start: visit.start, title: visit.title }
    assert_redirected_to event_path(assigns(:visit))
  end

  test "should destroy event" do
    assert_difference('Event.count', -1) do
      delete :destroy, id: visit
    end

    assert_redirected_to events_path
  end
end
