## admin user ##
@user = User.create!(name: "Ming",
  email: "ming.hentech@gmail.com",
  password: "password",
  password_confirmation: "password",
  activated: true,
  activated_at: Time.zone.now)

## admin user's division ##
@user.divisions.create!(
  name: "受託IT開発"
)
@user.divisions.create!(
  name: "都市農業サービス"
)
@user.divisions.create!(
  name: "アプリサービス提供"
)

## sample records ##


## accounts ##
Account.create!(
  name: "売上"
)
Account.create!(
  name: "売掛回収"
)
Account.create!(
  name: "売掛回収"
)
Account.create!(
  name: "資産購入"
)
Account.create!(
  name: "減価償却計上"
)
Account.create!(
  name: "仕入"
)
Account.create!(
  name: "棚卸"
)
Account.create!(
  name: "収入印紙代"
)
Account.create!(
  name: "梱包資材"
)
Account.create!(
  name: "送料"
)
Account.create!(
  name: "水道代"
)
Account.create!(
  name: "電気代"
)
Account.create!(
  name: "ガス代"
)
Account.create!(
  name: "水道光熱費"
)
Account.create!(
  name: "電車賃"
)
Account.create!(
  name: "バス代"
)
Account.create!(
  name: "タクシー代"
)
Account.create!(
  name: "高速道路等利用料"
)
Account.create!(
  name: "ガソリン代"
)
Account.create!(
  name: "宿泊費"
)
Account.create!(
  name: "旅費交通費"
)
Account.create!(
  name: "出張先飲食費"
)
Account.create!(
  name: "電話料金"
)
Account.create!(
  name: "インターネット利用料"
)
Account.create!(
  name: "サーバ等利用料"
)
Account.create!(
  name: "通信費"
)
Account.create!(
  name: "私書箱利用料"
)
Account.create!(
  name: "ソフトウェア利用料"
)
Account.create!(
  name: "クラウドサービス利用料"
)
Account.create!(
  name: "システム利用料"
)
Account.create!(
  name: "サンプル費"
)
Account.create!(
  name: "広告費"
)
Account.create!(
  name: "広報費"
)
Account.create!(
  name: "接待交際費"
)
Account.create!(
  name: "祝電代"
)
Account.create!(
  name: "挨拶状代"
)
Account.create!(
  name: "挨拶状代"
)
Account.create!(
  name: "贈答品費"
)
Account.create!(
  name: "損害保険料"
)
Account.create!(
  name: "設備修理費"
)
Account.create!(
  name: "メンテナンス費"
)
Account.create!(
  name: "備品購入費"
)
Account.create!(
  name: "消耗品費"
)
Account.create!(
  name: "事務用品費"
)
Account.create!(
  name: "印刷費"
)
Account.create!(
  name: "消耗品費"
)
Account.create!(
  name: "福利厚生費"
)
Account.create!(
  name: "給与"
)
Account.create!(
  name: "賞与"
)
Account.create!(
  name: "アルバイト代"
)
Account.create!(
  name: "雑給"
)
Account.create!(
  name: "謝礼"
)
Account.create!(
  name: "外注費"
)
Account.create!(
  name: "業務委託費"
)
Account.create!(
  name: "派遣受入費"
)
Account.create!(
  name: "支払利息"
)
Account.create!(
  name: "家賃"
)
Account.create!(
  name: "オフィスレンタル料"
)
Account.create!(
  name: "貸倒金"
)
Account.create!(
  name: "清掃料"
)
Account.create!(
  name: "会議費"
)
Account.create!(
  name: "管理費"
)
Account.create!(
  name: "新聞図書費"
)
Account.create!(
  name: "展示会等入場料"
)
Account.create!(
  name: "取材費"
)
Account.create!(
  name: "研修費"
)
Account.create!(
  name: "研究開発費"
)
Account.create!(
  name: "マーケティング調査費"
)
Account.create!(
  name: "銀行手数料"
)
Account.create!(
  name: "支払手数料"
)
Account.create!(
  name: "団体諸会費"
)
Account.create!(
  name: "レンタル料"
)
Account.create!(
  name: "雑費"
)