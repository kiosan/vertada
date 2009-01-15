class FsFile < ActiveRecord::Base
  
  belongs_to :idea
  belongs_to :uploader, :class_name=>"User"
  
  # This method handles the uploaded file object.
  # Sets the data field in the database to an uploaded file.  
  #   image = Image.new
  #   image.uploaded_data = params[:image][:data]
  def uploaded_data=(file_data)
    
    # don't save image if it wasn't changed
    return nil if file_data.nil? || file_data.size == 0 
    if !file_data.respond_to?(:read)
      raise InvalidImage, 'Uploaded file contains no binary data.  Be sure that {:multipart => true} is set on your form.'
    end
   
    self.size = file_data.size
    self.content_type = file_data.content_type.strip if file_data.respond_to?(:content_type)
    self.file_name = file_data.original_filename.strip if file_data.respond_to?(:original_filename)
    self.content = file_data.read
    @updated_image = true
  end
  
  def sanitize_filename(value)
    # get only the filename, not the whole path
    filename = value.gsub(/^.*(\\|\/)/, '')
    # NOTE: File.basename doesn't work right with Windows paths on Unix
    # INCORRECT: filename = File.basename(value.gsub('\\\\', '/')) 
    [ ["æ","ae"], ["ø","oe"], ["å","aa"] ].each do |int|
      filename = filename.gsub(int[0], int[1])
    end
    # Finally, replace all non alphanumeric, underscore or periods with underscore
    @filename = filename.gsub(/[^\w\.\-]/,'_')
  end
end
