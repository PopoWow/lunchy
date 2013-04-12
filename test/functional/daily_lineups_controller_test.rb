require 'test_helper'

class DailyLineupsControllerTest < ActionController::TestCase
  setup do
    @daily_lineup = daily_lineups(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:daily_lineups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create daily_lineup" do
    assert_difference('DailyLineup.count') do
      post :create, daily_lineup: { date: @daily_lineup.date }
    end

    assert_redirected_to daily_lineup_path(assigns(:daily_lineup))
  end

  test "should show daily_lineup" do
    get :show, id: @daily_lineup
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @daily_lineup
    assert_response :success
  end

  test "should update daily_lineup" do
    put :update, id: @daily_lineup, daily_lineup: { date: @daily_lineup.date }
    assert_redirected_to daily_lineup_path(assigns(:daily_lineup))
  end

  test "should destroy daily_lineup" do
    assert_difference('DailyLineup.count', -1) do
      delete :destroy, id: @daily_lineup
    end

    assert_redirected_to daily_lineups_path
  end
end
