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
# == Schema Information
#
# Table name: authorizations
#
#  id         :integer         not null, primary key
#  provider   :string(255)
#  uid        :string(255)
#  user_id    :integer
#  token      :string(255)
#  secret     :string(255)
#  name       :string(255)
#  link       :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

