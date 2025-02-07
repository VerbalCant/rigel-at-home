class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, :omniauthable,
         omniauth_providers: [:google_oauth2, :apple, :microsoft_office365],
         jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  def self.from_omniauth(auth)
    Rails.logger.info("ALAINA: Processing OAuth data: #{auth.inspect}")
    
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.name = auth.info.name
      user.password = Devise.friendly_token[0, 20]
      Rails.logger.info("ALAINA: Created new user from OAuth: #{user.inspect}")
    end
  end

  def jwt_payload
    {
      'email' => email,
      'name' => name,
      'provider' => provider,
      'uid' => uid
    }
  end
end
