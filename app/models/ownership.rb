class Ownership < ApplicationRecord
  belongs_to :user
  belongs_to :book
  has_many :ownership_categories, dependent: :destroy
  has_many :categories, through: :ownership_categories

  validates :user_id, uniqueness: { scope: :book_id }
end
