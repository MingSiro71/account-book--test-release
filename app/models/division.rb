class Division < ApplicationRecord
  belongs_to :user, optional: true
  has_many :records
  has_many :back_records
  validates :user_id, presence: true
  validates :name, presence: true
end
