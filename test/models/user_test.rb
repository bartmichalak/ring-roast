require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "generates name on create" do
    user = User.create!
    assert user.name.present?
    assert_match(/\A[A-Z][a-z]+[A-Z][a-z]+\d+\z/, user.name)
  end

  test "generates session_token on create" do
    user = User.create!
    assert user.session_token.present?
  end

  test "validates session_token uniqueness" do
    existing = users(:one)
    duplicate = User.new(name: "Test", session_token: existing.session_token)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:session_token], "has already been taken"
  end

  test "ow_user_id is optional" do
    user = User.create!
    assert_nil user.ow_user_id
  end

  test "generates unique names across multiple users" do
    names = 10.times.map { User.create!.name }
    assert_equal names.size, names.uniq.size
  end
end
