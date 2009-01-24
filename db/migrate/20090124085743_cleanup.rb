class Cleanup < ActiveRecord::Migration
  def self.up
    remove_column :ideas, :tags
    drop_table :idea_tags
    add_column :tag_sharings, :idea_id, :int
  end

  def self.down
    remove_column :tag_sharings, :idea_id, :int
    add_column :ideas, :tags, :string
    create_table :idea_tags do |t|
      t.integer :tag_sharing_id, :idea_id, :user_id
    end
    
  end
end
