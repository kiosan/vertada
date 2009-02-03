class SearchController < ApplicationController
  before_filter :login_required
  
  def tags
    @tag_ids = params[:tags].split(',').collect{|id| id.to_i}.delete_if{|i| i == 0}
    
    conditions = 'tag_id IN (%s)' % [ @tag_ids.join(',') ]
    @tags = current_user.tag_sharings.find(:all, :conditions=>conditions, :group=>'tag_id')
    
    joins = @tag_ids.collect{|id| 
      tag_join = 
        "INNER JOIN idea_tags @it ON  @it.idea_id = ideas.id AND  @it.tag_id = %d
         INNER JOIN tag_sharings @ts ON @it.user_id = @ts.owner_id AND @ts.tag_id = %d AND @ts.user_id = %d"
      tag_join.gsub!("@it", "it_#{id}")
      tag_join.gsub!("@ts", "ts_#{id}")
      tag_join % [id, id, current_user.id]
    }.join(" ")
    @ideas = Idea.find(:all, :joins=>joins, :group=>'ideas.id', :order=>"ideas.created_at DESC")
    
    @related_tags = []
    @ideas.each do |idea| 
      sharings = idea.tag_sharings_for_user(current_user)
      sharings.delete_if{|ts| !@tags.find{|t| t.tag_id == ts.tag_id}.nil? }
      @related_tags += sharings
    end
    @related_tags.uniq!
    
    @ideas = Idea.paginate(:page=>params[:page], :joins=>joins, :group=>'ideas.id', :order=>"ideas.created_at DESC")
  end
  
end
