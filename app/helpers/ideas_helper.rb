module IdeasHelper
  def can_edit_idea(idea)
    current_user.id == idea.user_id
  end
end
