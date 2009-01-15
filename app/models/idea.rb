class Idea < ActiveRecord::Base
  has_many :files, :class_name=>'FsFile'
  belongs_to :user
  validates_presence_of     :body
  
  @@per_page = 20
end
