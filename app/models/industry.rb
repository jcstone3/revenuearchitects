class Industry < ActiveRecord::Base
	has_many :companies
	has_many :questionnaires
end
# == Schema Information
#
# Table name: industries
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  value      :integer
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

