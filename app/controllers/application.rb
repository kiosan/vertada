# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  # You can move this into a different controller, if you wish.  This module gives you the require_role helpers, and others.
  include RoleRequirementSystem
    
  helper :all # include all helpers, all the time
  filter_parameter_logging :password, :password_confirmation
 
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  self.allow_forgery_protection = false
  #protect_from_forgery # :secret => CONFIG[:secret_protect_from_forgery]
  
  def group_by(enum)
    result = []
    enum.each do |value|
      result << value unless result.find {|val| yield(val) == yield(value)}
    end
    result
  end
end


class FManager
 

  def self.init(session)
    session[:uploaded_files] = {}
  end

  
  def self.add_file(session, post_id, file)
    session[:uploaded_files] ||= {}
    index = post_id.nil? ? "0" : post_id.to_s
    
    session[:uploaded_files][index] ||= []
    session[:uploaded_files][index] << {:id=>file.id, :name=>file.file_name, :content_type=>file.content_type}
    
  end
  
  def self.clear_for_post(session, post_id)
    index = post_id.nil? ? "0" : post_id.to_s
    if session[:uploaded_files] and session[:uploaded_files][index]
      session[:uploaded_files][index] = []
    end
  end
  
  def self.remove_file(session, post_id, id)
    index = post_id.nil? ? "0" : post_id.to_s
    if session[:uploaded_files] and session[:uploaded_files][index]
      session[:uploaded_files][index].delete_if{|f| f[:id].to_i==id.to_i}
    end
  end
  
  def self.load_from_idea(session, idea)
    session[:uploaded_files][idea.id.to_s] ||= []
    uploaded_files = session[:uploaded_files][idea.id.to_s]
    idea.files.each do |f|
      uploaded_files << {:id=>f.id, :name=>f.file_name, :content_type=>f.content_type}
    end
  end
  
  def self.files_for_post(session, post_id)
    index = post_id.nil? ? "0" : post_id.to_s
    if session[:uploaded_files] and session[:uploaded_files][index]
      return session[:uploaded_files][index]
    end
    []
  end
  
  
end