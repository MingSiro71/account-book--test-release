class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.transrate(word, from, to)
    reference = dictionary
    reference.find{|item| item[:"#{from}"] == word}[:"#{to}"] || raise
  end

  def self.en_(word)
    transrate(word, "ja", "en")
  end

  def self.ja_(word)
    transrate(word, "en", "ja")
  end

  def self.tax_rates
    [0, 8, 10]
  end

  def self.dictionary
    array = [
      # Used in record (& both).
      {:ja=>"売上", :en=>"sales"},
      {:ja=>"仮払源泉徴収", :en=>"advance_withholding"},
      {:ja=>"売掛回収", :en=>"collection_of_bills"},
      {:ja=>"資産購入", :en=>"acquirement_of_assets"},
      {:ja=>"減価償却", :en=>"depreciation"},
      {:ja=>"仕入", :en=>"purchase"},
      {:ja=>"棚卸", :en=>"inventory"},
      {:ja=>"棚卸評価損", :en=>"inventory_valuation_loss"},
      {:ja=>"収入印紙代", :en=>"revenue_stamp_fee"},
      {:ja=>"梱包資材", :en=>"package_material"},
      {:ja=>"送料", :en=>"shipping_fee"},
      {:ja=>"水道代", :en=>"water_charge"},
      {:ja=>"電気代", :en=>"electricity_charge"},
      {:ja=>"ガス代", :en=>"gas_charge"},
      {:ja=>"水道光熱費", :en=>"utilities_charge"},
      {:ja=>"電車代", :en=>"train_fee"},
      {:ja=>"バス代", :en=>"bus_fee"},
      {:ja=>"タクシー代", :en=>"taxi_fare"},
      {:ja=>"高速道路等利用料", :en=>"highway_toll"},
      {:ja=>"ガソリン代", :en=>"gasoline"},
      {:ja=>"交通費", :en=>"transport_cost"},
      {:ja=>"宿泊費", :en=>"hotel_charge"},
      {:ja=>"旅費交通費", :en=>"travel_cost"},
      {:ja=>"出張先飲食費", :en=>"travel_food_expense"},
      {:ja=>"電話代", :en=>"call_expense"},
      {:ja=>"インターネット利用料", :en=>"internet_fee"},
      {:ja=>"サーバ等利用料", :en=>"server_fee"},
      {:ja=>"通信費", :en=>"communication_cost"},
      {:ja=>"私書箱利用料", :en=>"pobox_fee"},
      {:ja=>"ソフトウェア利用料", :en=>"software_fee"},
      {:ja=>"クラウドサービス利用料", :en=>"xaas_fee"},
      {:ja=>"システム利用料", :en=>"system_fee"},
      {:ja=>"サンプル費", :en=>"sample_cost"},
      {:ja=>"広告出稿費", :en=>"ad_publicity_fee"},
      {:ja=>"広報費", :en=>"pr_fee"},
      {:ja=>"接待交際費", :en=>"entertainment_expenses"},
      {:ja=>"祝電費", :en=>"telegram_fee"},
      {:ja=>"挨拶状代", :en=>"greeting_card_cost"},
      {:ja=>"贈答品費", :en=>"gift_cost"},
      {:ja=>"損害保険料", :en=>"insurance_premium"},
      {:ja=>"設備修理費", :en=>"equipment_repare_cost"},
      {:ja=>"メンテナンス費", :en=>"maintenance_cost"},
      {:ja=>"備品費", :en=>"equipment_cost"},
      {:ja=>"事務用品費", :en=>"office_supplies_cost"},
      {:ja=>"印刷費", :en=>"printing_cost"},
      {:ja=>"消耗品費", :en=>"supplies_cost"},
      {:ja=>"福利厚生費", :en=>"welfare_expence"},
      {:ja=>"給与", :en=>"payroll"},
      {:ja=>"賞与", :en=>"bonus_payment"},
      {:ja=>"アルバイト代", :en=>"wages_payment"},
      {:ja=>"雑給", :en=>"miscellaneous_pay"},
      {:ja=>"謝礼", :en=>"honorarium"},
      {:ja=>"外注費", :en=>"outsourcing_cost"},
      {:ja=>"業務委託費", :en=>"commission_expense"},
      {:ja=>"派遣料", :en=>"dispaching_fee"},
      {:ja=>"仮受源泉徴収", :en=>"incoming_withholding"},
      {:ja=>"仮受源泉納付", :en=>"withholding_payment"},
      {:ja=>"支払利息", :en=>"interest_expense"},
      {:ja=>"地代家賃", :en=>"rent"},
      {:ja=>"レンタルオフィス料", :en=>"rental_office_fee"},
      {:ja=>"貸倒金", :en=>"uncollectable_account"},
      {:ja=>"清掃費", :en=>"cleaning_expense"},
      {:ja=>"会議費", :en=>"conference_fee"},
      {:ja=>"管理費", :en=>"administrative_expense"},
      {:ja=>"新聞図書費", :en=>"newspaper_books_expense"},
      {:ja=>"展示会等入場料", :en=>"exhibision_admission_fee"},
      {:ja=>"取材費", :en=>"coverage_fee"},
      {:ja=>"従業員研修費", :en=>"training_expense"},
      {:ja=>"研究費", :en=>"reserch_expense"},
      {:ja=>"マーケティング調査費", :en=>"marketing_survey_cost"},
      {:ja=>"試作費", :en=>"testing_expense"},
      {:ja=>"銀行手数料", :en=>"bank_charge"},
      {:ja=>"手数料", :en=>"commissions"},
      {:ja=>"組合費等", :en=>"union_due"},
      {:ja=>"備品レンタル料", :en=>"lental_supply_fee"},
      {:ja=>"雑費", :en=>"sundries"},
      {:ja=>"消費税確定", :en=>"vat_fix"},
      {:ja=>"消費税納付", :en=>"vat_payment"},
      {:ja=>"租税公課", :en=>"taxes"},
      {:ja=>"雑収入", :en=>"miscellaneous_income"},
      # Used in backrecord and stats
      {:ja=>"事業主貸", :en=>"owner_withdrawal"},
      {:ja=>"事業主借", :en=>"owner_investment"},
      {:ja=>"売掛金", :en=>"account_recievable"},
      {:ja=>"消費税確定済売上", :en=>"vat_fixed_sales"},
      {:ja=>"固定資産", :en=>"assets"},
      {:ja=>"消費税相当額", :en=>"predefined_vat"},
      {:ja=>"繰越在庫", :en=>"carry_over_stock"},
      {:ja=>"期首棚卸高", :en=>"initial_inventory"},
      {:ja=>"期末棚卸高", :en=>"final_inventory"},
      {:ja=>"荷造運賃", :en=>"packing_freight"},
      {:ja=>"支払手数料", :en=>"commissions_payment"},
      {:ja=>"広告宣伝費", :en=>"advertising_expense"},
      {:ja=>"印刷製本費", :en=>"printing_and_binding"},
      {:ja=>"給与賃金", :en=>"conpensation"},
      {:ja=>"利子割引料", :en=>"interest_and_discount"},
      {:ja=>"教育研修費", :en=>"education_and_training"},
      {:ja=>"研究開発費", :en=>"r_and_d_expense"},
      {:ja=>"諸会費", :en=>"dues"},
      {:ja=>"レンタル料", :en=>"rental_fee"},
      {:ja=>"仮受消費税", :en=>"incoming_vat"},
      {:ja=>"支払消費税", :en=>"paid_vat"},
      # Used in stats
      {:ja=>"利益収支", :en=>"profit"},
      {:ja=>"キャッシュ収支", :en=>"cache"},
      {:ja=>"債権未回収分", :en=>"uncollected"},
      {:ja=>"資産購入時消費税", :en=>"vat_for_assets"},
      {:ja=>"在庫変動", :en=>"inventory_change"}
    ]
  end

end