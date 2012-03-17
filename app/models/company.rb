class Company < ActiveRecord::Base
	validates :name, :presence => true, :format => { :with => /\A[a-zA-Z]+\z/,
    		  :message => "Only letters allowed" }, :length => { :maximum => 30 }

    
	validates :website, :presence => true, :length => { :maximum => 30 },
			  :format => {:with => /^[a-zA-Z\d:\.\/]*$/i,:message =>"invalid url"} 
	
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

