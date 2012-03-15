class Survey < ActiveRecord::Base
	validates :size, :presence => true, :numericality => {:greater_than => 0}
	validates :revenue, :presence => true, :numericality => {:greater_than => 0}
	#validates :start_date, :presence => true
	#validates :end_date, :presence => true
    validates :company_id, :presence => true	
    
	belongs_to :company
	has_many :responses
end
# == Schema Information
#
# Table name: surveys
#
#  id         :integer         not null, primary key
#  company_id :integer
#  size       :integer
#  revenue    :integer
#  start_date :date
#  end_date   :date
#  is_active  :boolean
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

