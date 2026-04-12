class CardColorService
  VIBRANT_COLORS = %w[
    #FF6B35 #FF2D87 #7B2FF7 #00C9A7
    #FFD23F #3A86FF #F72585 #4CC9F0
    #06D6A0 #FB5607 #8338EC #FF006E
    #FFBE0B #00BBF9 #9B5DE5 #F15BB5
  ].freeze

  def self.colors(count:)
    VIBRANT_COLORS.sample(count)
  end
end
