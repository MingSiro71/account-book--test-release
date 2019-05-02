class User < ApplicationRecord
  validates :name, presence: true, length: {maximum: 20}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  # this does not follow internationalized domain name.
  # So you should fix if your customers use such email address.
  validates :email, presence: true, length: {maximum: 80}, format: {with: VALID_EMAIL_REGEX}
end
