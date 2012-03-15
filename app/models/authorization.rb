class Authorization < ActiveRecord::Base
	belongs_to :user

	# Maybe we'll cover twitter in another post?
  scope :twitter, where(:provider => 'twitter')
  scope :facebook, where(:provider => 'facebook')

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

