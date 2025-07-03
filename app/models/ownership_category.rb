class OwnershipCategory < ApplicationRecord
  belongs_to :ownership
  belongs_to :category

  validates :ownership_id, uniqueness: { scope: :category_id }
end
