class Idea < ActiveRecord::Base
  has_many :files, :class_name=>'FsFile'
  belongs_to :user
  has_many :idea_tags
  
  validates_presence_of     :body
  
  @@per_page = 20
  
  def quick_tags(user)
    []
  end
  
  def visible_tags_for(user)
    self.idea_tags
  end
  
end
