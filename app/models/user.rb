class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, :omniauth_providers => [:facebook]
  attr_accessible :email, :password, :password_confirmation, :name, :image, :phone
  has_one :owner
  has_one :walker
  
  
  # Facebook User Authentication
  def self.find_for_facebook_oauth(auth)
  	where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
  		user.provider = auth.provider
  		user.uid = auth.uid
  		user.email = auth.info.email
  		user.password = Devise.friendly_token[0,20]
	    user.name = auth.info.name
	    user.image = auth.info.image
	    user.save!

      # Creates Walker and Owner profiles
      walker = Walker.where(:user_id => user.id).first_or_create(:user_id => user.id)
      owner = Owner.where(:user_id => user.id).first_or_create(:user_id => user.id)    
	  end
  end
  
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end  
end
