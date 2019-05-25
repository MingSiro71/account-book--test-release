class Record < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :division, optional: true 
  belongs_to :account, optional: true
  has_many :back_records
  validates :account_id, presence: true
  validates :division_id, presence: true
  validates :amount, presence: true
  validates :when, presence: true
  validates :where, presence: true

  def store
    account = Account.find_by(id: self.account_id)
    raise unless account
    hash = self.back_record(account)
    back_record = BackRecord.new(hash)
    transaction do
      self.save!
      back_record.save!
    end
    rescue => e
      nil
  end

  def back_record(account) # Logic for converting record to backrecord.
    back_record = {}
    if account.name == "売上"
      back_record[:when] = self.when
      back_record[:amount] = self.amount
      back_record[:debit] = "事業主貸"
      back_record[:credit] = "売上"
      back_record[:division_id] = self.division_id
    elsif
      back_record[:when] = self.when
      back_record[:amount] = self.amount
      back_record[:debit] = account.name
      back_record[:credit] = "事業主借"
      back_record[:division_id] = self.division_id
    end
    back_record
  end
end
