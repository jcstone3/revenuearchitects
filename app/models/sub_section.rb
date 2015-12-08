class SubSection < ActiveRecord::Base

  default_scope where(:deleted_at => nil).order('sequence')

	validates :name, :presence => {:message=> "Name can't be blank"}
	validates :section_id, :presence => {:message=> "Select Section"}
	validates :description, :presence => {:message=> "Description can't be blank"}

	belongs_to :section
	has_many :questions, :dependent => :destroy

  def self.last_secuence
    (SubSection.last.nil? )? 1 :  SubSection.last.sequence.to_i + 1
  end

  def self.find_section_subsections(section_id)
    SubSection.find(:all,
    :select => "sub_sections.*",
    :joins => "inner join questions on questions.sub_section_id = sub_sections.id",
    :conditions=>"sub_sections.section_id =#{section_id}",
    :order => "questions.sequence ASC" )
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
