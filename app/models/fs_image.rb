require 'RMagick'

class FsImage < FsFile
  attr_accessor :updated_image
  
  
  def save_with_resize(width, height)
    binary_file_data = self.content
    image = Magick::Image::from_blob(binary_file_data).first
    image.change_geometry!(width.to_s + 'x' + height.to_s) { |cols, rows, img|
       img.resize!(cols, rows)   
    }   
    self.content = image.to_blob
    self.save
  end
end
