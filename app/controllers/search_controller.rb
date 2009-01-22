class SearchController < ApplicationController
  def tags
    @tag_ids = params[:tags].split(',').collect{|id| id.to_i}.delete_if{|i| i == 0}
    
    @tags = Tag.find(@tag_ids)
    
    
    joins = @tag_ids.collect{|id| "INNER JOIN idea_tags it_#{id} ON it_#{id}.idea_id = ideas.id AND it_#{id}.tag_id = #{id} 
                                   INNER JOIN tag_sharings AS ts_#{id} ON ts_#{id}.user_id = #{current_user.id} AND ts_#{id}.tag_id = #{id}" }.join(" ")
    
    select = "ideas.*"

    @ideas = Idea.find(:all, :select=>select, :joins=>joins, :include=>[:idea_tags], :group=>'ideas.id', :order=>"ideas.created_at DESC")
    related_tags = []
    @related_tags = []
    @ideas.each{|t| related_tags += t.visible_tags_for(current_user) }
    related_tags.each do |t|
      @related_tags << t.tag unless @tags.include?(t.tag)
    end
    @related_tags.uniq!
    
    @ideas = Idea.paginate(:all, :page =>params[:page], :per_page=>10,:select=>select, :joins=>joins, :include=>[:idea_tags], :group=>'ideas.id', :order=>"ideas.created_at DESC")
  end
  
end
