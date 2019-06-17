class BackRecord < ApplicationRecord
  belongs_to :division, optional: true
  belongs_to :record, optional: true
  validates :division_id, presence: true
  validates :record_id, presence: true
  validates :amount, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :when, presence: true
  validates :tax, presence: true, inclusion: { in: tax_rates }
  validates :debit, presence: true
  validates :credit, presence: true

  def self.period(division_ids, date_a, date_z)
    if date_z
      BackRecord.where("division_id IN (?)" ,division_ids).where(when: date_a..date_z)
    else
      BackRecord.where("division_id IN (?)" ,division_ids).where(when: date_a..date_a.end_of_month)
    end
  end

  def self.stats(back_records)
    stats = init_stats
    debits = {}
    credits = {}

    # Summarize back records for each account
    back_records.each do |b|
      if !debits[:"#{en_(b.debit)}"]
        debits[:"#{en_(b.debit)}"] = b.amount
      else
        debits[:"#{en_(b.debit)}"] += b.amount
      end
      if !credits[:"#{en_(b.credit)}"]
        credits[:"#{en_(b.credit)}"] = b.amount
      else
        credits[:"#{en_(b.credit)}"] += b.amount
      end
      # Summarize for each vat type
      if b.credit == "売上" || b.credit == "雑収入" 
        stats[:info][:"tax#{b.tax}"][:value] += b.amount
      else
        stats[:info][:"tax#{b.tax}"][:value] -= b.amount
      end
    end

    # Summarize for each stat
    debits.each do |k, v|
      # Fundamentals for profit (positive elements)
      # Which contributes to stats[:credits] and stats[:results][:profit]
      if k == en_('売上').to_sym # -
        stats[:credits][:"#{en_('売上')}"][:value] -= v
        stats[:results][:"#{en_('利益収支')}"][:value] -= v
        next
      elsif k == en_('消費税確定済売上').to_sym # -
        stats[:credits][:"#{en_('売上')}"][:value] -= v
        stats[:results][:"#{en_('利益収支')}"][:value] -= v
        next
      elsif k == en_('雑収入').to_sym # -
        stats[:credits][:"#{en_('雑収入')}"][:value] -= v
        stats[:results][:"#{en_('利益収支')}"][:value] -= v
        next
      # Fundamentals for cache (positive elements)
      # Which contributes only to stats[:results][:cache]
      elsif k == en_('事業主貸').to_sym
        stats[:results][:"#{en_('キャッシュ収支')}"][:value] += v
        next
      # Fundamentals for cache (negative elements)
      # Which contributes only to stats[:results][:cache]
      elsif k == en_('期首棚卸高').to_sym
        stats[:factors][:"#{en_('在庫変動')}"][:value] -= v
        next
      # Adjustments for between profit and cache (positive element)
      # Which contributes only to stats[:factors]
      elsif k == en_('仮受源泉徴収').to_sym # -
        stats[:factors][:"#{en_('仮受源泉徴収')}"][:value] -= v
        next
      elsif k == en_('仮受消費税').to_sym # -
        stats[:factors][:"#{en_('仮受消費税')}"][:value] -= v
        next
      # Adjustments for between profit and cache (negative element)
      # Which contributes only to stats[:factors]
      elsif k == en_('売掛金').to_sym
        stats[:factors][:"#{en_('債権未回収分')}"][:value] -= v
        next
      elsif k == en_('仮払源泉徴収').to_sym
        stats[:factors][:"#{en_('仮払源泉徴収')}"][:value] -= v
        next
      # Non cost payments is treated same as adjustment (negative element)
      # Which contributes to stats[:credits], stats[:debits] and stats[:factors]
      elsif k == en_('固定資産').to_sym
        stats[:debits][:"#{en_('資産購入')}"][:value] += v
        stats[:credits][:"#{en_('固定資産')}"][:value] += v
        stats[:factors][:"#{en_('資産購入')}"][:value] -= v
        next
      elsif k == en_('消費税相当額').to_sym
        stats[:debits][:"#{en_('資産購入時消費税')}"][:value] += v
        stats[:credits][:"#{en_('資産購入時消費税')}"][:value] += v
        stats[:factors][:"#{en_('資産購入')}"][:value] -= v
        next
      # Counterpart accounts which are not used in stats
      elsif k == en_('繰越在庫').to_sym
        next
      # Invalid accounts for credits
      elsif k == en_('期末棚卸高').to_sym
        next
      elsif k == en_('事業主借').to_sym
        next
      # Fundamentals for profit (negative elements)
      # Which contributes to stats[:debits] and stats[:results][:profit]
      else
        stats[:debits][k][:value] += v
        stats[:results][:"#{en_('利益収支')}"][:value] -= v
      end
    end

    credits.each do |k, v|
      # Fundamentals for profit (positive elements)
      # Which contributes to stats[:credits] and stats[:results][:profit]
      if k == en_('売上').to_sym
        stats[:credits][:"#{en_('売上')}"][:value] += v
        stats[:results][:"#{en_('利益収支')}"][:value] += v
        next
      elsif k == en_('消費税確定済売上').to_sym
        stats[:credits][:"#{en_('売上')}"][:value] += v
        stats[:results][:"#{en_('利益収支')}"][:value] += v
        next
      elsif k == en_('雑収入').to_sym
        stats[:credits][:"#{en_('雑収入')}"][:value] += v
        stats[:results][:"#{en_('利益収支')}"][:value] += v
        next
      # Fundamentals for cache (positive elements)
      # Which contributes only to stats[:results][:cache]
      elsif k == en_('期末棚卸高').to_sym
        stats[:factors][:"#{en_('在庫変動')}"][:value] += v
        next
      # Fundamentals for cache (negative elements)
      # Which contributes only to stats[:results][:cache]
      elsif k == en_('事業主借').to_sym
        stats[:results][:"#{en_('キャッシュ収支')}"][:value] -= v
        next
      # Adjustments for between profit and cache (positive element)
      # Which contributes only to stats[:factors]
      elsif k == en_('仮受源泉徴収').to_sym # -
        stats[:factors][:"#{en_('仮受源泉徴収')}"][:value] -= v
        next
      elsif k == en_('仮受消費税').to_sym # -
        stats[:factors][:"#{en_('仮受消費税')}"][:value] -= v
        next
      # Adjustments for between profit and cache (negative element)
      # Which contributes only to stats[:factors]
      elsif k == en_('売掛金').to_sym # -
        stats[:factors][:"#{en_('債権未回収分')}"][:value] += v
        next
      elsif k == en_('仮払源泉徴収').to_sym # -
        stats[:factors][:"#{en_('仮払源泉徴収')}"][:value] += v
        next
      elsif k == en_('固定資産').to_sym # -
        stats[:factors][:"#{en_('減価償却')}"][:value] += v
        next
      # Counterpart accounts which are not used in stats
      elsif k == en_('繰越在庫').to_sym
        next
      # Invalid accounts for credits
      elsif k == en_('期首棚卸高').to_sym
        next
      elsif k == en_('事業主貸').to_sym
        next
      elsif k == en_('消費税相当額').to_sym
        next
      # Fundamentals for profit (negative elements)
      # Which contributes to stats[:debits] and stats[:results][:profit]
      else
        stats[:debits][k][:value] -= v
        stats[:results][:"#{en_('利益収支')}"][:value] -= v
      end
    end

    # Exception: stock is made up only when final inventory is done in the month.
    # Rollback profit.
    unless credits[:"#{en_('期末棚卸高')}"]
      stats[:results][:"#{en_('利益収支')}"][:value] += stats[:debits][:"#{en_('期首棚卸高')}"][:value]
      stats[:factors][:"#{en_('在庫変動')}"][:value] += stats[:debits][:"#{en_('期首棚卸高')}"][:value]
    end

    stats
  end

  def self.init_stats
    stats = {
      :debits=>{
        # Cost
        :"#{en_('消耗品費')}"=>{title: "消耗品費", value: 0},
        :"#{en_('荷造運賃')}"=>{title: "荷造運賃", value: 0},
        :"#{en_('水道光熱費')}"=>{title: "水道光熱費", value: 0},
        :"#{en_('旅費交通費')}"=>{title: "旅費交通費", value: 0},
        :"#{en_('通信費')}"=>{title: "通信費", value: 0},
        :"#{en_('支払手数料')}"=>{title: "支払手数料", value: 0},
        :"#{en_('広告宣伝費')}"=>{title: "広告宣伝費", value: 0},
        :"#{en_('接待交際費')}"=>{title: "接待交際費", value: 0},
        :"#{en_('損害保険料')}"=>{title: "損害保険料", value: 0},        
        :"#{en_('管理費')}"=>{title: "管理費", value: 0},
        :"#{en_('消耗品費')}"=>{title: "消耗品費", value: 0},
        :"#{en_('印刷製本費')}"=>{title: "印刷製本費", value: 0},
        :"#{en_('福利厚生費')}"=>{title: "福利厚生費", value: 0},
        :"#{en_('給与賃金')}"=>{title: "給与賃金", value: 0},
        :"#{en_('賞与')}"=>{title: "賞与", value: 0},
        :"#{en_('雑給')}"=>{title: "雑給", value: 0},
        :"#{en_('雑費')}"=>{title: "雑費", value: 0},
        :"#{en_('外注費')}"=>{title: "外注費", value: 0},
        :"#{en_('利子割引料')}"=>{title: "利子割引料", value: 0},
        :"#{en_('地代家賃')}"=>{title: "地代家賃", value: 0},
        :"#{en_('貸倒金')}"=>{title: "貸倒金", value: 0},
        :"#{en_('会議費')}"=>{title: "会議費", value: 0},
        :"#{en_('新聞図書費')}"=>{title: "新聞図書費", value: 0},
        :"#{en_('取材費')}"=>{title: "取材費", value: 0},
        :"#{en_('教育研修費')}"=>{title: "教育研修費", value: 0},
        :"#{en_('研究開発費')}"=>{title: "研究開発費", value: 0},
        :"#{en_('諸会費')}"=>{title: "諸会費", value: 0},
        :"#{en_('レンタル料')}"=>{title: "レンタル料", value: 0},
        :"#{en_('租税公課')}"=>{title: "租税公課", value: 0},
        # Non cost
        :"#{en_('資産購入')}"=>{title: "資産購入", value: 0},
        # Supporting accounts
        :"#{en_('事業主貸')}"=>{title: "事業主貸", value: 0},
        :"#{en_('期首棚卸高')}"=>{title: "期首棚卸高", value: 0},
      },
      :credits=>{
        # Profit
        :"#{en_('売上')}"=>{title: "売上", value: 0},
        :"#{en_('雑収入')}"=>{title: "雑収入", value: 0},
        # Non profit
        :"#{en_('固定資産')}"=>{title: "固定資産", value: 0},
        # Supporting accounts
        :"#{en_('事業主借')}"=>{title: "事業主借", value: 0},
        :"#{en_('期末棚卸高')}"=>{title: "期末棚卸高", value: 0},
      },
      :results=>{
        :"#{en_('利益収支')}"=>{title: "利益収支", value: 0},
        :"#{en_('キャッシュ収支')}"=>{title: "キャッシュ収支", value: 0},
      },
      :factors=>{
        # factors are expressed as + when cache increase, - cache decrease.
        :"#{en_('債権未回収分')}"=>{title: "債権未回収分", value: 0},
        :"#{en_('仮払源泉徴収')}"=>{title: "仮払源泉徴収", value: 0},
        :"#{en_('仮受源泉徴収')}"=>{title: "仮受源泉徴収", value: 0},
        :"#{en_('仮受消費税')}"=>{title: "仮受消費税", value: 0},
        :"#{en_('在庫変動')}"=>{title: "在庫変動", value: 0},
        :"#{en_('資産購入')}"=>{title: "資産購入", value: 0},
        :"#{en_('減価償却')}"=>{title: "減価償却", value: 0},
        :"#{en_('資産購入時消費税')}"=>{title: "資産購入時消費税", value: 0},
      },
      :info=>{
        :tax10=>{title: "消費税率別収支:10%", value: 0},
        :tax8=>{title: "消費税率別収支:8%", value: 0},
        :tax0=>{title: "消費税率別収支:非課税", value: 0},
        :tax00=>{title: "消費税率別収支:不課税", value: 0},
      }
    }
    return stats
  end

  def en_(word)
    super
  end

end
