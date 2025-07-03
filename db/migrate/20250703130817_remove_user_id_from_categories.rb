class RemoveUserIdFromCategories < ActiveRecord::Migration[8.0]
  def change
    remove_reference :categories, :user, foreign_key: true
  end
end
