class User < ActiveRecord::Base
  attr_accessor :password
  before_save :encrypt_password

  validates :username, format: { with: /\A[\p{L}0-9]{6,}\z/ }, on: :create
  
  validates :password, format: { with: /\A[\p{L}0-9]{8,}\z/ }, on: :create

  validates :password, format: { with: /\A[\p{L}0-9]{8,}\z/ }, :allow_nil => true, on: :update

  validates :is_deleted, format: { with: /\A[1]{1,}\z/ }, :allow_nil => true, on: :update

  validates :email, presence: true, uniqueness: { case_sensitive: false }, on: :create
  
  def encrypt_password
    if password.present?
      self.password_salt = BCrypt::Engine.generate_salt
      self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
    end
  end
  
  

  def authenticate(email, password)
    user = User.find_by(email: email)
    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
      user
    else
      nil
    end
  end

end
