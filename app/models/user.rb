class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :omniauthable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username
  
  #assocciation
  has_many :authorizations, :dependent => :destroy
  has_many :companies
  
  #validations
  validates_presence_of :username, :message => "Name cannot be blank"
  validates_format_of :username, :with =>/^[a-z A-Z][a-z A-Z 0-9_]*$/, :message => "Name should contain only alphabets"
  validates_presence_of :password, :presence => true, :message  => "Password can't be blank"
  validates_length_of :password,  :within => 4..30, :message => "Password should be greater than 4 and less than 30"
  validates_presence_of :email, :message => "Email can't be blank"
  validates_uniqueness_of :email,     :case_sensitive => false, :allow_blank => true, :if => :email_changed?, :message=> "Email address already taken"
  validates_format_of :email, :with  => Devise.email_regexp, :allow_blank => true, :if => :email_changed?, :message => "Invalid email address"
 

#facebook authentication
def self.find_for_oauth(access_token, signed_in_resource=nil, provider)
    data = access_token.extra.raw_info
    if provider == "facebook"
        user = User.where(:email => data.email).first      
    else
        user = User.where(:username => data.name).first 
    end
    if user 
      user
    else # Create a user with a stub password. 
      if provider == "facebook"             
       User.create!(:email => data.email, :password => Devise.friendly_token[0,20], :username => data.first_name)  
      else
       User.create!(:email => "no_email@test.com", :password => Devise.friendly_token[0,20], :username => data.name)
      end     
    end
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"]
      end
    end
  end

end
# == Schema Information
#
# Table name: users
#
#  id                     :integer         not null, primary key
#  email                  :string(255)     default(""), not null
#  encrypted_password     :string(255)     default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer         default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime        not null
#  updated_at             :datetime        not null
#  username               :string(255)
#

