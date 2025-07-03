class CreateOwnerships < ActiveRecord::Migration[8.0]
  def change
    create_table :ownerships do |t|
      t.references :user, null: false, foreign_key: true
      t.string :amazon_url, null: false
      t.datetime :owned_at, null: false, default: -> { 'CURRENT_TIMESTAMP' }

      t.timestamps
    end
    add_index :ownerships, [:user_id, :amazon_url], unique: true
    add_index :ownerships, :amazon_url
  end
end
