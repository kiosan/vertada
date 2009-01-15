# GravatarTag module creates a simple view helper to embed gravatar in your ruby on rails application 
require 'digest/md5'

module GravatarTag
	#Usage: gravatar_tag "user@domain.com", :size => "60x60"
	def gravatar_tag(email, options = {})
		gravatar_id = Digest::MD5.hexdigest(email)
		default_options = {:size => "80x80"}
		options = default_options.merge options
		image_tag "http://www.gravatar.com/avatar.php?gravatar_id=#{gravatar_id}", options
	end
end