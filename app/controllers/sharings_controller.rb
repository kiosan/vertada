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
    
    if !(TagSharing.find(:first, :conditions=>['tag_id = ? AND user_id = ? AND owner_id = ?', tag.id, user.id, current_user.id]))
      share = TagSharing.create({:tag => tag, :user_id => user.id, :owner_id => current_user.id})
      render :update do |page|
        page.replace_html("my_shares", render(:partial=>"my_share", :locals=>{:share=>share}))
      end
      
    else
      render :nothing=>true
    end
  end
  
  def destroy
    TagSharing.destroy(params[:id])
    render :update do |page|
      page.remove('share_' + params[:id])
    end
  end
  
  private 
  
 
end
