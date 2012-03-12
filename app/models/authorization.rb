class Authorization < ActiveRecord::Base
	belongs_to :user

	def provider_name
  if provider == 'open_id'
    "OpenID"
  else
    provider.titleize
  end
end

protected
def handle_unverified_request
  true
end

end
