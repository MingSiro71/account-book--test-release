class BackRecord < ApplicationRecord
  belongs_to :division, optional: true
  belongs_to :record, optional: true
  validates :division_id, presence: true
end
