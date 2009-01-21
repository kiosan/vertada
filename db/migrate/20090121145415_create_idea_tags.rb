class CreateIdeaTags < ActiveRecord::Migration
  def self.up
    create_table :idea_tags do |t|
      t.integer :tag_sharing_id, :idea_id, :user_id
    end
  end

  def self.down
    drop_table :idea_tags
  end
end
