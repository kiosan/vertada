class SharingsController < ApplicationController
  before_filter :login_required
  
  def index
    sharings = TagSharing.find(:all, :conditions=>["(owner_id = ? OR user_id=?)", current_user.id, current_user.id], :order=>'id desc');
    shared, unshared = sharings.partition{|share| share.owner_id != share.user_id}
    @sharings_to_me, @sharings_by_me = shared.partition {|s| s.owner_id != current_user.id }
    
    @sharings_by_me = group_by(@sharings_by_me) {|t| [t.tag_id, t.user_id]}
    @sharings_to_me = group_by(@sharings_to_me) {|t| [t.tag_id, t.user_id]}
    @unshared_tags = group_by(unshared){|t| t.tag_id}
  end
  
  def create
    tag = Tag.find(params[:tag_id_for_share])
    user = User.find(:first, :conditions=>['login = ? OR email = ?', params[:user_for_share], params[:user_for_share]])
    return unless tag && user
    
    options = {:tag => tag, :user_id => user.id, :owner_id => current_user.id, :idea_id=>nil}
    conds = ['tag_id = ? AND owner_id = ?', tag.id, current_user.id]
    TagSharing.find(:all, :conditions=>conds, :group=>'idea_id').each do |idea_share| 
      TagSharing.create(options.update({:idea_id=>idea_share.idea_id}))
    end
    
    render :nothing=>true
  end
  
  def destroy
    
  end
  
  private 
  
  def group_by(enum)
    result = []
    enum.each do |value|
      result << value unless result.find {|val| yield(val) == yield(value)}
    end
    result
  end
end
