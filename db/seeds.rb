# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#load seed admin user
Admin.delete_all

@admin = Admin.new
@admin.email = "admin@revenuegrader.com"
@admin.name = "admin"
@admin.password = "revenue@123"
@admin.password_confirmation = "revenue@123"
@admin.save

Industry.delete_all
 ['Agriculture','Business & Professional Services', 'Construction','Consumer Services', 'Education', 'Energy Utilities & Waste',
  'Banking','Wealth Management','Insurance','Legal Services','Manufacturing','Media & Entertainment','Metals & Mining','Organizations',
  'Real Estate','Retail','Technology and Software','Telecommunications','Transportation','Health Care & Life Sciences',
  'Hospitality','Other'].each do |industry|    	  
    Industry.create!(:name=>industry, :value=>industry)        
 end  