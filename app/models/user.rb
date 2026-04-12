class User < ApplicationRecord
  ADJECTIVES = %w[
    Funky Sleepy Chaotic Dramatic Salty Turbo Spicy Crusty Snoozy Rogue
    Cosmic Feral Toasty Crunchy Zesty Wobbly Sneaky Grumpy Dizzy Bouncy
    Fizzy Sassy Rusty Gloomy Peppy Wacky Cheeky Cranky Fluffy Moody
    Blazing Twisted Savage Mellow Crispy Foggy Jolly Bonkers Sluggish Rowdy
  ].freeze

  ANIMALS = %w[
    Panda Sloth Flamingo Narwhal Platypus Capybara Axolotl Otter Raccoon Penguin
    Corgi Gecko Quokka Wombat Hedgehog Alpaca Walrus Toucan Lemur Chameleon
    Ocelot Mantis Puffin Dingo Armadillo Bison Chinchilla Falcon Iguana Jellyfish
    Koala Lobster Meerkat Newt Ostrich Piranha Quail Stingray Tapir Vulture
  ].freeze

  validates :name, presence: true
  validates :session_token, presence: true, uniqueness: true

  before_validation :generate_session_token, on: :create
  before_validation :generate_name, on: :create

  private

  def generate_session_token
    self.session_token ||= SecureRandom.urlsafe_base64(32)
  end

  def generate_name
    self.name ||= "#{ADJECTIVES.sample}#{ANIMALS.sample}#{rand(100)}"
  end
end
