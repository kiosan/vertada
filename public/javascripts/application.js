// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var LiveValidationFix = {
	Format : null,
	FixMultiline : function(pattern) {
	  	if(pattern) {
			var str = pattern.toString();
			var mstr = str.replace('\\A', '^').replace('\\z', '$');
			if(mstr.length != str.length) {
				pattern = eval(mstr + 'm;');
			}
		}
		return pattern;
	},
	FormatFix : function(value, paramsObj) {
		var pattern = paramsObj.pattern || null;
		if(pattern) 
			paramsObj.pattern = LiveValidationFix.FixMultiline(pattern);
		return LiveValidationFix.Format(value, paramsObj);
	}
}
LiveValidationFix.Format = Validate.Format;
Validate.Format = LiveValidationFix.FormatFix;

$j = jQuery.noConflict();

function show_loader(container_id, image ) 
{ 
	if (!image) image = 'snake';
	with($(container_id))
	{
		innerHTML = '<img src="/images/'+ image +'.gif" />';
		show();
	}
}

 function show_delete_link(id){
   if (!$('delete_' + id).hasClassName("edit")){
     $('delete_' + id).show();
   }
 }
 function hide_delete_link(id){
   $('delete_' + id).hide();
 }
 
var Idea = 
{
	backupContent:function(id, force){
		var content_div = $('content_' + id);
		if(!content_div.__backupHTML || force){
			content_div.__backupHTML = content_div.innerHTML;
		}
	},
	restoreContent:function(id){
		var content_div = $('content_' + id);
    var content_id = '#content_' + id
		content_div.innerHTML = content_div.__backupHTML;
	
		var updated = $('idea_updated_'+ id)
		if (updated) updated.hide();
	  $j(content_id).effect("highlight", {}, 1000);
	}
}