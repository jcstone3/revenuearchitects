class Company < ActiveRecord::Base
	validates :name, :presence => {:message => "Company name can't be blank"}, :format => { :with => /\A[a-z A-Z -]+\z/,
    		  :message => "Only letters allowed" }, :length => { :maximum => 40 }

    
	validates :website, :presence => {:message => "Website url can't be blank"}, :length => { :maximum => 40 },
			  :format => {:with => /^(http:\/\/|https:\/\/|www\.)[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)*$/i,:message =>"Invalid url"} 
	
	validates :user_id, :presence => true
    validates :industry_id, :presence => {:message => "Industry can't be blank"}, :numericality => true
    
	belongs_to :user
	belongs_to :industry
	has_many :surveys

	scope :get_all_companies, lambda{|survey_company_id, company_industry_id|{
          :select => "industries.id, companies.id",
   		  :joins =>"right outer join industries on companies.industry_id = industries.id",   
          :conditions=>"industries.id = #{company_industry_id} and companies.id !=#{survey_company_id}"
    }}
   
    scope :get_companies_belonging_to_same_industry, lambda{|company_industry_id|{
    	  :conditions=>"industry_id=#{company_industry_id}"
    	}}

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

