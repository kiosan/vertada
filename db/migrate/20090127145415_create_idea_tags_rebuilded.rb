class CreateIdeaTagsRebuilded < ActiveRecord::Migration
  def self.up
    create_table :idea_tags do |t|
      t.integer :tag_id, :idea_id, :user_id
    end
    remove_column :tag_sharings, :idea_id
  end

  def self.down
    drop_table :idea_tags
    add_column :tag_sharings, :idea_id, :int
  end
end
