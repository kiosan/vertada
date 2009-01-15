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
   $('delete_' + id).show();
 }
 function hide_delete_link(id){
   $('delete_' + id).hide();
 }