class SearchController < ApplicationController
  before_filter :login_required
  
  def tags
    @tag_ids = params[:tags].split(',').collect{|id| id.to_i}.delete_if{|i| i == 0}
    
    conditions = 'tag_id IN (%s)' % [ @tag_ids.join(',') ]
    @tags = current_user.tag_sharings.find(:all, :conditions=>conditions, :group=>'tag_id')
    
    joins = @tag_ids.collect{|id| 
      tag_join = "INNER JOIN tag_sharings ts_#{id} ON ideas.id = ts_#{id}.idea_id AND ts_#{id}.user_id = %d AND ts_#{id}.tag_id = %d"
      tag_join % [current_user.id, id]
    }.join(" ")
    @ideas = Idea.find(:all, :joins=>joins, :group=>'ideas.id', :include=>[:tag_sharings], :order=>"ideas.created_at DESC")
    
    @related_tags = []
    @ideas.each do |idea| 
      sharings = idea.tag_sharings_for_user(current_user)
      sharings.delete_if{|ts| !@tags.find{|t| t.tag_id == ts.tag_id}.nil? }
      @related_tags += sharings
    end
    @related_tags.uniq!
    
    @ideas = Idea.paginate(:page=>params[:page], :joins=>joins, :group=>'ideas.id', :include=>[:tag_sharings], :order=>"ideas.created_at DESC")
  end
  
end
