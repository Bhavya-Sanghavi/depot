require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "should not save user without a name" do
    user = User.new(password: "secret")
    assert_not user.save
  end

  test "should not save user with a duplicate name" do
    user = User.new(
      name: users(:one).name,
      password: "secret"
    )
    assert_not user.save
  end

  test "should save user with a name and password" do
    user = User.new(
      name: "new_user",
      password: "secret"
    )
    assert user.save
  end
end
