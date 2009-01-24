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
    owner_sharings, user_sharings = (self.tag_sharings.select{|ts| ts.user_id == user.id} || []).partition{|ts| ts.owner_id == user.id}
    
    user_sharings.each do |ts| 
      owner_sharings += [ts] unless owner_sharings.find{|os| os.owner_id == ts.user_id}
    end
    owner_sharings
  end
  
end
