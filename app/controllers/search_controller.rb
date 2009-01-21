class SearchController < ApplicationController
  def tags
    @tag_ids = params[:tags].split(',').collect{|id| id.to_i}.delete_if{|i| i == 0}
    
    @tags = TagSharing.find(@tag_ids)
    
    
    
    
    joins = @tag_ids.collect{|id| "INNER JOIN idea_tags it_#{id} ON it_#{id}.idea_id = ideas.id AND it_#{id}.tag_sharing_id = #{id}" }.join(" ")
    
    joins << " INNER JOIN tag_sharings AS ts ON ts.user_id = #{current_user.id} "
    
    select = "ideas.*"

    @ideas = Idea.paginate(:all, :page =>params[:page], :per_page=>10,:select=>select, :joins=>joins, :include=>[:idea_tags], :group=>'ideas.id')
    
    related_tags = []
    @related_tags = []
    @ideas.each{|t| related_tags += t.visible_tags_for(current_user) }
    related_tags.each do |t|
      @related_tags << t unless @tags.include?(t.tag_sharing)
    end
    @related_tags.uniq!
  end
  
end
