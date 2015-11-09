class SubSection < ActiveRecord::Base

    default_scope where(:deleted_at => nil)

	validates :name, :presence => {:message=> "Name can't be blank"}
	validates :section_id, :presence => {:message=> "Select Section"}
	validates :description, :presence => {:message=> "Description can't be blank"}

	belongs_to :section
	has_many :questions, :dependent => :destroy

  def self.last_secuence
    (SubSection.last.nil? )? 1 :  SubSection.last.sequence.to_i + 1 
  end

end
# == Schema Information
#
# Table name: sub_sections
#
#  id          :integer         not null, primary key
#  name        :string(255)
#  description :string(255)
#  order       :string(255)
#  is_active   :boolean
#  section_id  :integer
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

