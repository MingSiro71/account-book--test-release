class Record < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :division, optional: true 
  belongs_to :account, optional: true
  validates :account_id, presence: true
  validates :division_id, presence: true
  validates :amount, presence: true
  validates :when, presence: true
  validates :where, presence: true

  def store
    account = Account.find_by(id: self.account_id)
    raise unless account
    hash = self.back_record(account.name)
    back_record = BackRecord.new(hash)
    transaction do
      self.save!
      back_record.save!
    end
    rescue => e
      byebug
      nil
  end

  def back_record(account) # Logic for converting record to backrecord.
    back_record = {}
    if account == "売上"
      back_record[:when] = self.when
      back_record[:amount] = self.amount
      back_record[:debit] = "事業主貸"
      back_record[:credit] = "売上"
      back_record[:division_id] = self.division_id
    else
      back_record[:when] = self.when
      back_record[:when] = self.when
    end
    back_record
  end
end
