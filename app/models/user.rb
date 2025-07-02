class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true
  validates :provider, presence: true

  class << self
    def find_auth_user(auth)
      User.find_by(provider: auth['provider'], uid: auth['uid'])
    end

    def create_with_auth(auth)
      User.create(
        name: auth['info']['email'].split('@').first,
        provider: auth['provider'],
        uid: auth['uid']
      )
    end
  end
end
