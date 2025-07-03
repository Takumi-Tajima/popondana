class AddBookToOwnerships < ActiveRecord::Migration[8.0]
  def change
    add_reference :ownerships, :book, null: false, foreign_key: true
  end
end
