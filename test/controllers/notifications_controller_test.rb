require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @notification = notifications(:one)
  end

  test "should get index" do
    get notifications_url
    assert_response :success
    assert_select "div[data-controller='notifications']", 1
  end

  test "should show notification permission modal elements on index" do
    get notifications_url
    assert_response :success
    # Verificar que o modal está presente no DOM
    assert_select "div[data-notifications-target='permissionModal']", 1
    assert_select "button[data-action='notifications#requestPermissionFromModal']", 1
    assert_select "button[data-action='notifications#closePermissionModal']", 1
    # Verificar elementos do modal
    assert_select ".modal-title", text: /Ative as Notificações/i
    assert_select ".modal-body"
  end

  test "should have proactive modal with benefits list" do
    get notifications_url
    assert_response :success
    # Verificar que lista de benefícios está presente
    assert_select ".benefits-list", 1
    assert_select ".benefits-list li", minimum: 3
  end

  test "should have modal backdrop for proper UX" do
    get notifications_url
    assert_response :success
    # Verificar que o backdrop está presente
    assert_select "div[data-notifications-target='modalBackdrop']", 1
  end

  test "should display unread count when there are unread notifications" do
    # Criar algumas notificações não lidas
    get notifications_url
    assert_response :success
    assert_select ".notifications-summary"
  end

  test "should show notification" do
    get notification_url(@notification)
    assert_response :success
  end

  test "should mark notification as read" do
    assert_not @notification.read
    post mark_as_read_notification_url(@notification)
    assert_redirected_to notifications_path
    @notification.reload
    assert @notification.read
  end

  test "should mark all notifications as read" do
    post mark_all_as_read_notifications_url
    assert_redirected_to notifications_path
    assert Notification.unread.count == 0
  end

  test "should destroy notification" do
    assert_difference("Notification.count", -1) do
      delete notification_url(@notification)
    end
    assert_redirected_to notifications_path
  end

  test "should get unread count as json" do
    get unread_count_notifications_url
    assert_response :success
    json_response = JSON.parse(response.body)
    assert json_response.key?("count")
    assert json_response["count"] >= 0
  end
end

