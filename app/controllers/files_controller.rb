class FilesController < ApplicationController
  def avatar
    image = FsImage.find_by_id(params[:id])
    if (image != nil)
        data = FilesHelper.store_avatar_to_cache(image)
        send_data(data, :filename => image.file_name, :disposition => 'inline')
    else
        render :text => ''
    end
  end
  
  def download
    file_name = params[:name]
    file_name << ".#{params[:f1]}" if params[:f1]
    file_name << ".#{params[:f2]}" if params[:f2]
    
    f = FsFile.find_by_id(params[:id])
    if (f != nil)
        send_data(f.content, :filename => f.file_name, :disposition => 'inline')
    else
        render :text => ''
    end
  end
 end