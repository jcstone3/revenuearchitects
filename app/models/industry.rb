class Industry < ActiveRecord::Base
	validates :name, :presence => true
	validates :value, :presence => true #, :numericality => {:greater_than => 0}

	has_many :companies
	has_many :questionnaires
end
# == Schema Information
#
# Table name: industries
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  value      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

