require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
    @not_activated = users(:notactivated)
    @not_activated.activated = false
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user, index|
      unless user == @not_activated
        assert_select 'a[href=?]', user_path(user), text: user.name
      end
      unless user == @admin || user == @not_activated
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end

  test "only show activated users" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a[href=?]', user_path(@not_activated), {text: @not_activated.name, count: 0}
  end
end
