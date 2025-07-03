class Book < ApplicationRecord
  has_many :ownerships, dependent: :destroy
  has_many :users, through: :ownerships

  validates :isbn, presence: true
  validates :title, presence: true
end
