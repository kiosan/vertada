class Tag < ActiveRecord::Base
  has_many :tag_sharings
end
