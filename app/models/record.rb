class Record < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :division, optional: true, dependent: :destroy 
  belongs_to :account, optional: true
  has_many :back_records
  validates :account_id, presence: true
  validates :division_id, presence: true
  validates :amount, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :when, presence: true
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

  def new_back_records(account) # Logic for converting record to backrecord.
    back_records = send("logic_#{ApplicationRecord.en_(account.name)}")
  end

  private
  
  def logic_common_income(credit)
    back_records = []
    hash = {}
    hash[:amount] = self.amount
    hash[:tax] = self.tax
    hash[:when] = self.when
    hash[:division_id] = self.division_id
    hash[:debit] = "事業主貸"
    hash[:credit] = credit
    back_records[0] = BackRecord.new(hash)
    back_records
  end

  def logic_common_cost(debit)
    back_records = []
    hash = {}
    hash[:amount] = self.amount
    hash[:tax] = self.tax
    hash[:when] = self.when
    hash[:division_id] = self.division_id
    hash[:debit] = debit
    hash[:credit] = "事業主借"
    back_records[0] = BackRecord.new(hash)
    back_records
  end

  def logic_sales
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
    else
      raise
    end
    back_records
  end

  def logic_仮払源泉徴収
    if self.option == nil
      hash = {}
      hash[:amount] = self.amount
      hash[:tax] = 0
      hash[:when] = self.when
      hash[:division_id] = self.division_id
      hash[:debit] = "売上"
      hash[:credit] = "消費税確定済売上"
      back_records[0] = BackRecord.new(hash)
      hash = {}
      hash[:amount] = self.amount
      hash[:tax] = 0
      hash[:when] = self.when
      hash[:division_id] = self.division_id
      hash[:debit] = "仮払源泉徴収"
      hash[:credit] = "事業主借"
      back_records[1] = BackRecord.new(hash)
    elsif self.option == "aftertax"
      hash = {}
      hash[:amount] = self.amount
      hash[:tax] = 0
      hash[:when] = self.when
      hash[:division_id] = self.division_id
      hash[:debit] = "仮払源泉徴収"
      hash[:credit] = "事業主借"
      back_records[0] = BackRecord.new(hash)
    end
    back_records
  end

  def logic_売掛回収
    hash = {}
    hash[:amount] = self.amount
    hash[:tax] = 0
    hash[:when] = self.when
    hash[:division_id] = self.division_id
    hash[:debit] = "事業主貸"
    hash[:credit] = "売掛金"
    back_records[0] = BackRecord.new(hash)
    back_records
  end

  def logic_資産購入
    if self.option == nil
      hash = {}
      hash[:amount] = substance = (self.amount.to_f*(100.0/108.0)).to_i
      hash[:tax] = self.tax
      hash[:when] = self.when
      hash[:division_id] = self.division_id
      hash[:debit] = "固定資産"
      hash[:credit] = "事業主借"
      back_records[0] = BackRecord.new(hash)
      hash = {}
      hash[:amount] = self.amount - substance
      hash[:tax] = self.tax
      hash[:when] = self.when
      hash[:division_id] = self.division_id
      hash[:debit] = "消費税相当額"
      hash[:credit] = "事業主借"
      back_records[1] = BackRecord.new(hash)
    elsif self.option == "tax_exempt"
      hash = {}
      hash[:amount] = self.amount
      hash[:tax] = self.tax
      hash[:when] = self.when
      hash[:division_id] = self.division_id
      hash[:debit] = "固定資産"
      hash[:credit] = "事業主借"
      back_records[0] = BackRecord.new(hash)
    else
      raise
    end
    back_records
  end

  def logic_減価償却
    # 減価償却のoptionは"定額法,5"のように方法と年数で引き継ぐ
    # 定率法については公式があるが、行政の一覧表を持つか利用者に計算させるかどちらかしかない
    if self.option == nil
      hash = {}
      hash[:amount] = self.amount
      hash[:tax] = 0
      hash[:when] = self.when
      hash[:division_id] = self.division_id
      hash[:debit] = "減価償却"
      hash[:credit] = "固定資産"
      back_records[0] = BackRecord.new(hash)
    elsif self.option.include?("定額法")
      term = (self.option.split(",")[1]).to_i
      for i in 1..term
        hash = {}
        hash[:amount] = 1 != term ? (self.amount.to_f*(1/term)).ceil : self.amount - ((self.amount.to_f*(1/term)).ceil) * (term-1)
        hash[:tax] = 0
        hash[:when] = self.when.since(i.years)
        hash[:division_id] = self.division_id
        hash[:debit] = "減価償却"
        hash[:credit] = "固定資産"
        back_records[i] = BackRecord.new(hash)
      end
    end
    back_records
  end

  def logic_仕入
    logic_common_cost("仕入")
  end

  def logic_棚卸
    hash = {}
    hash[:amount] = self.amount
    hash[:tax] = 0
    hash[:when] = self.when
    hash[:division_id] = self.division_id
    hash[:debit] = "繰越在庫"
    hash[:credit] = "期末棚卸高"
    back_records[0] = BackRecord.new(hash)
    hash = {}
    hash[:amount] = self.amount
    hash[:tax] = 0
    hash[:when] = self.when.at_beginning_of_month.next_month
    hash[:division_id] = self.division_id
    hash[:debit] = "期首棚卸高"
    hash[:credit] = "繰越在庫"
    back_records[1] = BackRecord.new(hash)
    back_records
  end

  def logic_revenue_stamp_fee
    logic_common_cost("消耗品費")
  end

  def logic_package_material
    logic_common_cost("荷造運賃")
  end

  def logic_shipping_fee
    logic_common_cost("荷造運賃")
  end

  def logic_water_charge
    logic_common_cost("水道光熱費")
  end

  def logic_electricity_charge
    logic_common_cost("水道光熱費")
  end

  def logic_gas_charge
    logic_common_cost("水道光熱費")
  end

  def logic_utilities_charge
    logic_common_cost("水道光熱費")
  end

  def logic_train_fee
    logic_common_cost("旅費交通費")
  end

  def logic_bus_fee
    logic_common_cost("旅費交通費")
  end

  def logic_taxi_fare
    logic_common_cost("旅費交通費")
  end

  def logic_highway_toll
    logic_common_cost("旅費交通費")
  end

  def logic_gasoline
    logic_common_cost("旅費交通費")
  end

  def logic_transport_cost
    logic_common_cost("旅費交通費")
  end

  def logic_hotel_charge
    logic_common_cost("旅費交通費")
  end

  def logic_travel_cost
    logic_common_cost("旅費交通費")
  end

  def logic_travel_food_expense
    logic_common_cost("旅費交通費")
  end

  def logic_call_expense
    logic_common_cost("通信費")
  end

  def logic_internet_fee
    logic_common_cost("通信費")
  end

  def logic_server_fee
    logic_common_cost("通信費")
  end

  def logic_communication_cost
    logic_common_cost("通信費")
  end

  def logic_pobox_fee
    logic_common_cost("通信費")
  end

  def logic_software_fee
    logic_common_cost("支払手数料")
  end

  def logic_xaas_fee
    logic_common_cost("支払手数料")
  end

  def logic_system_fee
    logic_common_cost("支払手数料")
  end

  def logic_pr_fee
    logic_common_cost("広告宣伝費")
  end

  def logic_sample_cost
    logic_common_cost("広告宣伝費")
  end

  def logic_ad_publicity_fee
    logic_common_cost("広告宣伝費")
  end

  def logic_entertainment_expenses
    logic_common_cost("接待交際費")
  end

  def logic_telegram_fee
    logic_common_cost("接待交際費")
  end

  def logic_greeting_card_cost
    logic_common_cost("接待交際費")
  end

  def logic_gift_cost
    logic_common_cost("接待交際費")
  end

  def logic_insurance_premium
    logic_common_cost("損害保険料")
  end

  def logic_equipment_repare_cost
    logic_common_cost("管理費")
  end

  def logic_maintenance_cost
    logic_common_cost("管理費")
  end

  def logic_equipment_cost
    logic_common_cost("消耗品費")
  end

  def logic_office_supplies_cost
    logic_common_cost("消耗品費")
  end

  def logic_printing_cost
    if self.option == nil
      logic_common_cost("消耗品費")
    elsif self.option == "promotional"
      logic_common_cost("広告宣伝費")
    elsif self.option == "publish"
      logic_common_cost("印刷製本費")
    else
      raise
    end
  end

  def logic_supplies_cost
    logic_common_cost("消耗品費")
  end

  def logic_welfare_expence
    logic_common_cost("福利厚生費")
  end

  def logic_payroll
    logic_common_cost("給与賃金")
  end

  def logic_bonus_payment
    logic_common_cost("賞与")
  end

  def logic_wages_payment
    logic_common_cost("雑給")
  end

  def logic_honorarium
    logic_common_cost("雑費")
  end

  def logic_commission_expense
    logic_common_cost("外注費")
  end

  def logic_dispaching_fee
    logic_common_cost("外注費")
  end

  def logic_outsourcing_cost
    logic_common_cost("外注費")
  end

  def logic_incoming_withholding
    hash = {}
    hash[:amount] = self.amount
    hash[:tax] = 0
    hash[:when] = self.when
    hash[:division_id] = self.division_id
    hash[:debit] = "事業主貸"
    hash[:credit] = "仮受源泉徴収"
    back_records[0] = BackRecord.new(hash)
    back_records
  end

  def logic_withholding_payment
    hash = {}
    hash[:amount] = self.amount
    hash[:tax] = 0
    hash[:when] = self.when
    hash[:division_id] = self.division_id
    hash[:debit] = "仮受源泉徴収"
    hash[:credit] = "事業主借"
    back_records[0] = BackRecord.new(hash)
    back_records
  end

  def logic_interest_expense
    logic_common_cost("利子割引料")
  end

  def logic_rent
    logic_common_cost("地代家賃")
  end

  def logic_rental_office_fee
    logic_common_cost("地代家賃")
  end

  def logic_uncollectable_account
    logic_common_cost("貸倒金")
  end

  def logic_cleaning_expense
    logic_common_cost("管理費")
  end

  def logic_conference_fee
    logic_common_cost("会議費")
  end

  def logic_administrative_expense
    logic_common_cost("管理費")
  end

  def logic_newspaper_books_expense
    logic_common_cost("新聞図書費")
  end

  def logic_exhibision_admission_fee
    logic_common_cost("取材費")
  end

  def logic_coverage_fee
    logic_common_cost("取材費")
  end

  def logic_training_expense
    logic_common_cost("教育研修費")
  end

  def logic_marketing_survey_cost
    logic_common_cost("研究開発費")
  end

  def logic_reserch_expense
    logic_common_cost("研究開発費")
  end

  def logic_testing_expense
    logic_common_cost("研究開発費")
  end

  def logic_bank_charge
    logic_common_cost("支払手数料")
  end

  def logic_commissions
    logic_common_cost("支払手数料")
  end

  def logic_union_due
    logic_common_cost("諸会費")
  end

  def logic_lental_supply_fee
    logic_common_cost("レンタル料")
  end

  def logic_taxes
    logic_common_cost("租税公課")
  end

  def logic_vat_fix
    hash = {}
    hash[:amount] = self.amount
    hash[:tax] = 0
    hash[:when] = self.when
    hash[:division_id] = self.division_id
    hash[:debit] = "売上"
    hash[:credit] = "仮受消費税"
    back_records[0] = BackRecord.new(hash)
    back_records
  end

  def logic_vat_payment
    hash = {}
    hash[:amount] = self.amount
    hash[:tax] = 0
    hash[:when] = self.when
    hash[:division_id] = self.division_id
    hash[:debit] = "仮受消費税"
    hash[:credit] = "事業主借"
    back_records[0] = BackRecord.new(hash)
    back_records
  end

  def logic_miscellaneous_income
    logic_common_income("雑収入")
  end

  def self.en_(word)
    super
  end

end
