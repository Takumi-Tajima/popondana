class User < ApplicationRecord
  has_many :ownerships, dependent: :destroy
  has_many :books, through: :ownerships
  has_many :categories, -> { distinct }, through: :ownerships

  validates :name, presence: true
  validates :provider, presence: true

  class << self
    def find_auth_user(auth)
      User.find_by(provider: auth['provider'], uid: auth['uid'])
    end

    def create_with_auth(auth)
      User.create(
        name: auth['info']['name'] || auth['info']['email'].split('@').first,
        image_url: auth['info']['image'],
        provider: auth['provider'],
        uid: auth['uid']
      )
    end
  end
end
