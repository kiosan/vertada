class IdeaTag < ActiveRecord::Base
  belongs_to :idea
  belongs_to :tag_sharing
  belongs_to :tag
  belongs_to :user
end
