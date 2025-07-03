class CreateBooks < ActiveRecord::Migration[8.0]
  def change
    create_table :books do |t|
      t.string :isbn, null: false
      t.string :title, null: false
      t.string :author
      t.string :publisher
      t.date :published_date
      t.string :image_url
      t.string :rakuten_url

      t.timestamps
    end
    add_index :books, :isbn, unique: true
  end
end
