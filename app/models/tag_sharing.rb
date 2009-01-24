class TagSharing < ActiveRecord::Base
  belongs_to :tag
  belongs_to :user
  belongs_to :owner, :class_name=>'User'
end
