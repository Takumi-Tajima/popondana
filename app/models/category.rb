class Category < ApplicationRecord
  has_many :ownership_categories, dependent: :destroy
  has_many :ownerships, through: :ownership_categories
  has_many :users, -> { distinct }, through: :ownerships

  validates :name, presence: true, uniqueness: true
end
