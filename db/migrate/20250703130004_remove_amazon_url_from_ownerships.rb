class RemoveAmazonUrlFromOwnerships < ActiveRecord::Migration[8.0]
  def change
    remove_column :ownerships, :amazon_url, :string
  end
end
