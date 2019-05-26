class Record < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :division, optional: true, dependent: :destroy 
  belongs_to :account, optional: true
  has_many :back_records
  validates :account_id, presence: true
  validates :division_id, presence: true
  validates :amount, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :when, presence: true
  validates :where_or_where_from , presence: true
  validates :tax, presence: true, inclusion: { in: tax_rates }

  def store
    account = Account.find_by(id: self.account_id)
    raise unless account
    if self.disabled
      back_records = BackRecord.where(record_id: self.id)
      transaction do
        self.save!
        back_records.each do |b|
          b.destroy!
        end
      end
    else
      back_records = new_back_records(account)
      transaction do
        self.save!
        self.reload
        back_records.each do |b|
          b.record_id = self.id
          b.save!
        end
      end
    end
    rescue => e
      nil
  end

 private

  def where_or_where_from
    where.presence or where_from.presence
  end

  def new_back_records(account) # Logic for converting record to backrecord.
    back_records = send("logic_#{account.name}")
  end

  def logic_売上
    back_records = []
    if self.option == nil # 即日支払の場合
      hash = {}
      hash[:amount] = self.amount
      hash[:tax] = self.tax
      hash[:when] = self.when
      hash[:division_id] = self.division_id
      hash[:debit] = "事業主貸"
      hash[:credit] = "売上"
      back_records[0] = BackRecord.new(hash)
    elsif self.option == "credit_selling" # 掛売の場合
      hash = {}
      hash[:amount] = self.amount
      hash[:tax] = self.tax
      hash[:when] = self.when
      hash[:division_id] = self.division_id
      hash[:debit] = "売掛金"
      hash[:credit] = "売上"
      back_records[0] = BackRecord.new(hash)
    elsif self.option == "withholding" # 源泉徴収分
      hash = {}
      hash[:amount] = self.amount
      hash[:tax] = self.tax
      hash[:when] = self.when
      hash[:division_id] = self.division_id
      hash[:debit] = "仮払税金"
      hash[:credit] = "売上"
      back_records[0] = BackRecord.new(hash)
    else
      raise
    end
    back_records
  end
  
end
