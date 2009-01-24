class Idea < ActiveRecord::Base
  has_many :files, :class_name=>'FsFile'
  belongs_to :user
  has_many :tag_sharings
  
  validates_presence_of     :body
  
  @@per_page = 20
  
  def quick_tags(user)
    []
  end
  
  def tag_sharings_for_user(user)
    self.tag_sharings.select{|ts| ts.user_id == user.id} || []
  end
  
end
