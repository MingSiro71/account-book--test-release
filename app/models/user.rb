class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token, :reset_token
  has_many :divisions
  before_save :downcase_email
  before_create :create_activation_digest 
  validates :name, presence: true, length: {maximum: 20}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  # this does not follow internationalized domain name.
  # So you should fix if your customers use such email address.
  validates :email, presence: true, length: {maximum: 80},
              format: {with: VALID_EMAIL_REGEX},
              uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password, presence: true, length: {minimum: 8}

  def self.digest(string) # you need 'self' if you call it from fixture.
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def self.new_token # generate randam token by urlsafe_base64
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def authenticated?(attribute, token) # remember_token should be called from cookies.
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget(id)
    user = User.find_by(id: id)
    user.update_attribute(:remember_digest, nil)
  end

  def activate
    self.update_attribute(:activated, true)
    self.update_attribute(:activated_at, Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    @time = Time.zone.now
    UserMailer.password_reset(self, @time).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

 private

  def downcase_email
    self.email = email.downcase
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

end
