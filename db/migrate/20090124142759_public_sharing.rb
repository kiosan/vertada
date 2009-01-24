class PublicSharing < ActiveRecord::Migration
  def self.up
    add_column :tag_sharings, :public, :boolean, :default=>false
  end

  def self.down
    remove_column :tag_sharings, :public
  end
end
