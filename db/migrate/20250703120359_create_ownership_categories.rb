class CreateOwnershipCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :ownership_categories do |t|
      t.references :ownership, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
    add_index :ownership_categories, [:ownership_id, :category_id], unique: true
  end
end
