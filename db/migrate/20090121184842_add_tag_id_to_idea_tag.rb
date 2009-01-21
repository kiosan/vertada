class AddTagIdToIdeaTag < ActiveRecord::Migration
  def self.up
    add_column :idea_tags, :tag_id, :integer
    add_column :tags, :style, :string
    
    tags = IdeaTag.find(:all)
    tags.each do |it|
      it.tag_id = it.tag_sharing.tag_id
      it.save
    end
    
  end

  def self.down
    remove_column :idea_tags, :tag_id
    remove_column :tags, :style
  end
end
