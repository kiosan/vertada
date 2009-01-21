# Methods added to this helper will be available to all templates in the application.
require 'htmlentities'
require 'bbcodeizer'
module ApplicationHelper
  def flash_helper
     f_names = [:notice, :success, :error]
     fl = ""
     for name in f_names
      if flash[name]
        fl = fl + "<div class=\"#{name.to_s}\">#{flash[name]}</div>"
        end
        flash[name] = nil;
     end
     if fl.length > 0
       fl = "<div id='flash_messages'>" + fl + "</div>";
     end
     return fl
 end
 
 def formatted_time(d, include_time = true)
    ApplicationHelper.formatted_time(d, include_time)
 end
 
 def self.eql_by_mod(d1, d2, mod)
    val1 = d1.to_i.divmod(mod)[0]
    val2 = d2.to_i.divmod(mod)[0]
    val1 == val2
  end
 
 def self.formatted_time(d, include_time = true)
    return "" if d.nil?
    now = Time.now
    if eql_by_mod(d, now, 86400)
      date = "Today"[:today] + " "
    elsif eql_by_mod(d, now - 86400, 86400) 
      date = "Yesterday"[:yesterday] + " "
    elsif eql_by_mod(d, now, 604800)
      date_format = "on"[:on_week_day] + " %A " 
      date = d.strftime(date_format)   
    else
      date_format = "%d %B" + (now.year != d.year ? " %Y " : " ")
      date = d.strftime(date_format)   
      date = date[1..date.length] if d.day < 10
    end
    if include_time
      time_format = '%H:%M'
      time = d.strftime(time_format)
      time = time[1..time.length] if d.hour < 10
      date + 'at'[:at_time] + ' ' + time
    else
      date
    end
  end
  
  def html_encode(str, bbencode = false)
    coder = HTMLEntities.new(bbencode ? 'bbcode' : 'xhtml1')
    str = coder.encode(str, :basic)
    str = bbcodeize(str) if bbencode
    str
  end
  
  def html_decode(str)
    coder = HTMLEntities.new
    coder.decode(str)
  end
  
  def tag_toggle_uri(tag_id)
   tag_ids = controller.request.path_parameters[:tags].split(',').collect{|id| id.to_i}.delete_if{|i| i == 0} if request.path_parameters[:tags]
   tag_ids = [] if tag_ids.nil?
   
   if tag_ids.include?(tag_id)
     tag_ids = tag_ids - [tag_id]
   else
     tag_ids = tag_ids + [tag_id]
   end
   current_url_add({:tags=>tag_ids.join(','), :page=>[]})
 end
 
 def streamlined_top_menus
   [
    ["View site", home_path],
    ["Manage Roles", {:controller=>"admin/roles"}],
    ["Manage Users", {:controller=>"admin/users"}]
   ]
 end
 
 def streamlined_side_menus
   [
    ["Manage Roles", {:controller=>"admin/roles"}],
    ["Manage Users", {:controller=>"admin/users"}]
   ]
 end
 
 def streamlined_branding
    "<h2>#{CONFIG[:site_title]}</h2>"
 end
 
 def streamlined_footer
    "#{ link_to "<b>#{CONFIG[:site_title]}</b>", "http://vertical-align.com" }"
 end
end
