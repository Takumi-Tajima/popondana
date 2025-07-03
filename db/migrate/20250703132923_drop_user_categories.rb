class DropUserCategories < ActiveRecord::Migration[8.0]
  def change
    drop_table :user_categories do |t|
      t.references :user, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.timestamps
    end
  end
end
