class ActionController::Base
  before_filter :set_locale
  # Helper method for starting
  def set_locale
    params[:language] ||= session[:language]
    LocalizeExt::Helper.start(session[:language] = params[:language])
  end
end