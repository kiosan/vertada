module ForulioEditorHelper
  # creates a text_area for the given object/field pair
  # and keeps track of the ID used (necessary for bb_editor_initialize)
  def forulio_editor(object, field, options={})
    editor_id = options[:id] || '%s_%s' % [object, field]
    options.update({:cols=>40, :rows=>7})
    output = "<div id='#{editor_id}_toolbar' class='forulio-toolbar'></div>"
    output << text_area(object, field, options)
    output << '<script type="text/javascript">'
    output << 'new ForulioEditor("%s");' % [editor_id]
    output << '</script>'
    output
  end
  
  def forulio_editor_support
    output = []
    output << stylesheet_link_tag('forulio-editor') 
    output << javascript_include_tag('forulio-editor')
    output << javascript_include_tag('forulio-editor-buttons')
    output.join("\n")
  end
end