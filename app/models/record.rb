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

  def logic_収入印紙代
    logic_common_cost("消耗品費")
  end

  def logic_梱包資材
    logic_common_cost("荷造運賃")
  end

  def logic_送料
    logic_common_cost("荷造運賃")
  end

  def logic_水道代
    logic_common_cost("水道光熱費")
  end

  def logic_電気代
    logic_common_cost("水道光熱費")
  end

  def logic_ガス代
    logic_common_cost("水道光熱費")
  end

  def logic_水道光熱費
    logic_common_cost("水道光熱費")
  end

  def logic_電車代
    logic_common_cost("旅費交通費")
  end

  def logic_バス代
    logic_common_cost("旅費交通費")
  end

  def logic_タクシー代
    logic_common_cost("旅費交通費")
  end

  def logic_高速道路等利用料
    logic_common_cost("旅費交通費")
  end

  def logic_ガソリン代
    logic_common_cost("旅費交通費")
  end

  def logic_交通費
    logic_common_cost("旅費交通費")
  end

  def logic_宿泊費
    logic_common_cost("旅費交通費")
  end

  def logic_旅費交通費
    logic_common_cost("旅費交通費")
  end

  def logic_出張先飲食費
    logic_common_cost("旅費交通費")
  end

  def logic_電話代
    logic_common_cost("通信費")
  end

  def logic_インターネット利用料
    logic_common_cost("通信費")
  end

  def logic_サーバ等利用料
    logic_common_cost("通信費")
  end

  def logic_通信費
    logic_common_cost("通信費")
  end

  def logic_私書箱利用料
    logic_common_cost("通信費")
  end

  def logic_ソフトウェア利用料
    logic_common_cost("支払手数料")
  end

  def logic_クラウドサービス利用料
    logic_common_cost("支払手数料")
  end

  def logic_システム利用料
    logic_common_cost("支払手数料")
  end

  def logic_広報費
    logic_common_cost("広告宣伝費")
  end

  def logic_サンプル費
    logic_common_cost("広告宣伝費")
  end

  def logic_広告出稿費
    logic_common_cost("広告宣伝費")
  end

  def logic_接待交際費
    logic_common_cost("接待交際費")
  end

  def logic_祝電費
    logic_common_cost("接待交際費")
  end

  def logic_挨拶状代
    logic_common_cost("接待交際費")
  end

  def logic_贈答品費
    logic_common_cost("接待交際費")
  end

  def logic_損害保険料
    logic_common_cost("損害保険料")
  end

  def logic_設備修理費
    logic_common_cost("管理費")
  end

  def logic_メンテナンス費
    logic_common_cost("管理費")
  end

  def logic_備品費
    logic_common_cost("消耗品費")
  end

  def logic_事務用品費
    logic_common_cost("消耗品費")
  end

  def logic_印刷費
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

  def logic_消耗品費
    logic_common_cost("消耗品費")
  end

  def logic_福利厚生費
    logic_common_cost("福利厚生費")
  end

  def logic_給与
    logic_common_cost("給与賃金")
  end

  def logic_賞与
    logic_common_cost("賞与")
  end

  def logic_アルバイト代
    logic_common_cost("雑給")
  end

  def logic_謝礼
    logic_common_cost("雑費")
  end

  def logic_業務委託費
    logic_common_cost("外注費")
  end

  def logic_派遣料
    logic_common_cost("外注費")
  end

  def logic_外注費
    logic_common_cost("外注費")
  end

  def logic_仮受源泉徴収
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

  def logic_仮受源泉納付
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

  def logic_支払利息
    logic_common_cost("利子割引料")
  end

  def logic_地代家賃
    logic_common_cost("地代家賃")
  end

  def logic_レンタルオフィス利用料
    logic_common_cost("地代家賃")
  end

  def logic_貸倒金
    logic_common_cost("貸倒金")
  end

  def logic_清掃料
    logic_common_cost("管理費")
  end

  def logic_conference_fee
    logic_common_cost("会議費")
  end

  def logic_管理費
    logic_common_cost("管理費")
  end

  def logic_新聞図書費
    logic_common_cost("新聞図書費")
  end

  def logic_展示会等入場料
    logic_common_cost("取材費")
  end

  def logic_取材費
    logic_common_cost("取材費")
  end

  def logic_従業員研修費
    logic_common_cost("教育研修費")
  end

  def logic_マーケティング調査費
    logic_common_cost("研究開発費")
  end

  def logic_研究費
    logic_common_cost("研究開発費")
  end

  def logic_試作費
    logic_common_cost("研究開発費")
  end

  def logic_銀行手数料
    logic_common_cost("支払手数料")
  end

  def logic_手数料
    logic_common_cost("支払手数料")
  end

  def logic_組合費等
    logic_common_cost("諸会費")
  end

  def logic_備品レンタル料
    logic_common_cost("レンタル料")
  end

  def logic_租税公課
    logic_common_cost("租税公課")
  end

  def logic_消費税確定
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

  def logic_消費税納付
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

  def logic_雑収入
    logic_common_income("雑収入")
  end

  def self.en_(word)
    super
  end

end
