class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username
  
  #assocciation
  has_many :authorizations, :dependent => :destroy
  
  #validations
  validates_presence_of :username, :message => "username cannot be blank"
  validates_length_of :username, :within => 4..20, :message => "username should be greater than 4 and less than 20"
  validates_presence_of :password, :message => "password cannot be blank"
  validates_length_of :password,  :within => 4..10, :message => "password should be greater than 4 and less than 10"
  validates_presence_of :email, :message => "email cannot be blank"

  def apply_omniauth(omniauth)
     self.email = omniauth['user_info']['email'] if email.blank?
     authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'])
  end

#def password_required?
#  (authentications.empty? || !password.blank?) && super
#end


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

