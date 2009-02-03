class Idea < ActiveRecord::Base
  has_many :files, :class_name=>'FsFile'
  belongs_to :user
  has_many :idea_tags, :dependent=>:delete_all
  
  validates_presence_of     :body
  
  @@per_page = 20
  
  def quick_tags(user)
    []
  end
  
  def tag_sharings_for_user(user)
    joins = "INNER JOIN idea_tags ON tag_sharings.tag_id = idea_tags.tag_id AND idea_tags.user_id = tag_sharings.owner_id"
    conditions = ["tag_sharings.user_id = ? AND idea_tags.idea_id = ?", user.id, self.id]
    TagSharing.find(:all, :joins=>joins, :conditions=>conditions)
  end
  
end
