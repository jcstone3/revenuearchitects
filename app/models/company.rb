class Company < ActiveRecord::Base
	belongs_to :user
	belongs_to :industry
	has_many :surveys
end
# == Schema Information
#
# Table name: companies
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  website     :string(255)
#  user_id     :integer
#  industry_id :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

