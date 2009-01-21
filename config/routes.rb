ActionController::Routing::Routes.draw do |map|
  
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil 
  
  map.file      'files/:id/:name',                      :controller=>'files',    :action => 'download'
  map.file1     'files/:id/:name.:f1',                  :controller=>'files',    :action => 'download'
  map.file2     'files/:id/:name.:f1.:f2',              :controller=>'files',    :action => 'download'

  
  map.resources :users, :member => { :suspend => :put, :unsuspend => :put, :purge => :delete, :check_user_login=>:get, :check_user_email=>:get}  
  map.resource :session
  
  map.resources :ideas
  
  map.delete_tag 'delete_tag/:tag_id/:idea_id', :controller => 'ideas', :action => 'delete_tag'
  
  
  map.tags_filter 'search/tags/:tags', :controller=>'search', :action=>'tags' 
  
  
  map.upload_file 'upload_file', :controller=>"ideas", :action=>'upload_file' 
  map.connect 'delete_file/:id', :controller=>"ideas", :action=>'delete_file' 
  map.delete_file 'delete_file/:id/:idea_id', :controller=>"ideas", :action=>'delete_file' 
  
  map.resources :groups
   
  
  map.home '/home', :controller=>"home", :action => 'index'
  
  
  map.change_password 'change_password', :controller => 'passwords', :action => 'update'
  map.forgot_password 'forgot_password', :controller => 'passwords', :action => 'create' 
  map.reset_password  'recover_password/:key', :controller => 'passwords', :action => 'show'

  map.resource :password
  
  map.main '/', :controller=>'content', :action=>'index' 
 
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
