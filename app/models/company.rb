class Company < ActiveRecord::Base
	validates :name, :presence => true, :format => { :with => /\A[a-z A-Z -]+\z/,
    		  :message => "Only letters allowed" }, :length => { :maximum => 40 }

    
	validates :website, :presence => true, :length => { :maximum => 40 },
			  :format => {:with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)*$/i,:message =>"Invalid url"} 
	
	validates :user_id, :presence => true
    validates :industry_id, :presence => true, :numericality => true
    
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

