require "test_helper"

module OpenWearables
  class ListUserConnectionsTest < ActiveSupport::TestCase
    test "returns empty array when user has no ow_user_id" do
      user = users(:anonymous)
      client = Object.new
      client.define_singleton_method(:connections) { |**_| raise "should not be called" }

      assert_equal [], ListUserConnections.new(user: user, client: client).call
    end

    test "fetches connections by ow_user_id when present" do
      user = users(:connected)
      client = Object.new
      client.define_singleton_method(:connections) do |user_id:|
        [ { "provider" => "oura", "user_id" => user_id, "status" => "active" } ]
      end

      result = ListUserConnections.new(user: user, client: client).call

      assert_equal 1, result.size
      assert_equal "ow-user-123", result.first["user_id"]
    end
  end
end
