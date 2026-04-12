require "test_helper"

class CardColorServiceTest < ActiveSupport::TestCase
  test "returns requested number of colors" do
    assert_equal 4, CardColorService.colors(count: 4).size
  end

  test "returns no duplicate colors" do
    colors = CardColorService.colors(count: 6)
    assert_equal colors.size, colors.uniq.size
  end

  test "returns valid hex colors" do
    CardColorService.colors(count: 4).each do |color|
      assert_match(/\A#[0-9A-F]{6}\z/i, color)
    end
  end
end
