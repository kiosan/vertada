class IdeasController < ApplicationController
  
  before_filter :login_required
  
  def index
    @shared_tags = current_user.tag_sharings.find(:all, :conditions=>["owner_id != user_id"])
    @ideas = current_user.ideas.paginate(:page=>params[:page], :order=>"created_at DESC")
  end
  
  def create
    @idea = Idea.new
    @idea.body = params[:idea][:body]
    @idea.user_id = current_user.id
    if @idea.save
      FManager.files_for_post(session, nil).each do |file|
        f = FsFile.find(file[:id])
        f.idea_id = @idea.id
        f.save
      end
    end
    render :update do |page|
        idea_id = 'new_idea'
        if @idea.save
          
          
          FManager.clear_for_post(session, nil)
          
          
          page.replace_html "uploaded_files", :partial=>"uploaded_files", :locals=>{:files=>[]} 
          
          page << 'if($("errorExplanation"))Element.hide("errorExplanation");'
          flash.now[:success] = "Idea saved. Now you have place for one more ;)"
          #Insert new row on same page
            page.replace_html  'idea_place', render(:partial => 'ideas/idea', :locals=>{:idea=>@idea})
            page.replace_html  'add_idea_place', render(:partial => 'ideas/quick_add', :locals=>{:idea=>Idea.new})
            page.replace_html  'flash', flash_helper
            page << "$j('#add_idea_place').effect(\"highlight\", {}, 1000);" 

            page[:new_idea].value = ''
        else
          #display error
          page.replace_html  "add_idea_place", render(:partial => 'ideas/quick_add', :locals=>{:idea=>@idea})
          page << "$j('#add_idea_place').effect(\"highlight\", {}, 1000);" 
        end
      
    end
  end
  
  def edit
    @idea = Idea.find_by_id(params[:id])
    return if @idea.nil? 
    id = @idea.id
    content_id = "content_#{@idea.id}"
    render :update do |page|
        if can_edit_idea(@idea)
          page << "Idea.backupContent(#{@idea.id});";
          page.replace_html  content_id, render(:partial => 'ideas/edit', :locals=>{:idea => @idea})
          page["delete_#{id}"].addClass("edit")
          page << "$j('##{content_id}').effect(\"highlight\", {}, 1000);"
        end
    end
  end
  
  def update_idea
    @idea = Idea.find_by_id(params[:id])
    return if @idea.nil? 
    id = @idea.id
    render :update do |page|
      content_id = "content_#{@idea.id}"
      if can_edit_idea(@idea)
        if @idea.update_attribute('body', params[:idea][:body])
          FManager.clear_for_post(session, @idea.id)
          page.replace_html content_id, render(:partial => 'ideas/updated', :locals=>{:idea => @idea})
          page << "Idea.backupContent(#{@idea.id}, true);"
          page << "$j('##{content_id}').effect(\"highlight\", {}, 1000);" 
          page["delete_#{id}"].removeClass("edit")
        else
          page.replace_html  content_id, render(:partial => 'ideas/edit', :locals=>{:idea => @idea})
          page << "$j('##{content_id}').effect(\"highlight\", {}, 1000);"
        end
      end
   end
  end
  
  def destroy
    @idea = current_user.ideas.find(params[:id])
    id = @idea.id
    @idea.files.each do |f|
      f.destroy
    end
    @idea.destroy
    render :update do |page|  
      page<< "$j(\"#idea_c_#{id}\").hide(\"fast\");"
    end
  end

  def upload_file
    upl_data = params[:fs_file][:uploaded_data] unless params[:fs_file].nil? 
    idea_id=params[:idea_id] ? params[:idea_id].to_i : nil
    
    if upl_data and upl_data.size > 0 and upl_data.size < CONFIG[:max_upload_file_size]
      @file = FsFile.new()
      @file.uploaded_data = upl_data 
      @file.uploader_id = current_user.id
      if @file.save
        FManager.add_file(session, idea_id, @file)
      end
    else
      @err_message = "Please select file with size less then"[:upload_file_size_limit]
    end
    uploaded_files_id, q_file_id  = "uploaded_files", "q_file"
    uploaded_files_id << "_#{params[:idea_id]}" unless idea_id.nil?
    q_file_id << "_#{params[:idea_id]}" unless idea_id.nil?
    respond_to_parent {
      render :update do |page|  
        page.replace_html uploaded_files_id, :partial=>"ideas/uploaded_files", :locals=>{:files=>FManager.files_for_post(session, idea_id), :idea_id=>idea_id} 
        page.replace_html q_file_id, :partial=>"ideas/upload_file_form", :locals=>{:idea_id=>idea_id}
       end
    }
  end
  
  def delete_file
    idea_id=params[:idea_id] ? params[:idea_id].to_i : nil
    file = FsFile.find_by_id(params[:id])
    
    uploaded_files_id  = "uploaded_files"
    uploaded_files_id << "_#{params[:idea_id]}" unless idea_id.nil?


    if idea_id
      idea = Idea.find_by_id(idea_id)
      FManager.load_from_idea(session, idea)
    end
    if (file.uploader==current_user) and file.destroy
      FManager.remove_file(session, idea_id, file.id)
      render :update do |page|  
          page.replace_html uploaded_files_id, :partial=>"uploaded_files", :locals=>{:files=>FManager.files_for_post(session, idea_id), :idea_id=>idea_id} 
      end
    end
  end
  
  
  def add_tags
    tags = params[:tags].split(",")
    idea = Idea.find_by_id(params[:id]) unless tags.empty?
    if tags.empty?
      render :text=>nil
      return
    end
    tags.each do |tag_ttl|    
      
      tag = TagSharing.find(:first, :conditions=>["tags.name=?",tag_ttl], :include=>[:tag])
      
      if tag.nil?
        tag1 = Tag.create(:name=>tag_ttl)
        tag = TagSharing.create({:tag => tag1, :user => current_user, :owner_id => current_user.id})
      end
      
      unless idea.visible_tags_for(current_user).include?(tag)
        IdeaTag.create!(:tag_sharing_id=>tag.id, :tag_id => tag.tag_id, :idea_id=>idea.id, :user_id=>current_user.id)
        idea.reload
      end
    end
    
    render :update do |page| 
       page << "$j('#tags_#{idea.id}').show();"
       page.replace_html "tags_#{idea.id}", :partial=>"tags", :locals=>{:tags=>idea.visible_tags_for(current_user), :idea=>idea}
       page << "$j('#add_tags_#{idea.id}').effect(\"highlight\", {}, 1000);"
    end
  end
  
  def delete_tag
    IdeaTag.delete_all(["idea_id=? and tag_id=? and user_id=?", params[:idea_id], params[:tag_id], current_user.id])
   
    idea = Idea.find_by_id(params[:idea_id])
    render :update do |page| 
      page.replace_html "tags_#{idea.id}", :partial=>"tags", :locals=>{:tags=>idea.visible_tags_for(current_user), :idea=>idea}
      page.replace_html "add_tags_#{idea.id}", :partial=>"ideas/add_tags", :locals=>{:idea=>idea}
      page << "$j('#tags_#{idea.id}').hide();" if idea.visible_tags_for(current_user).length == 0 
    end
  end
  
end
