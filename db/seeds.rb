## admin user ##
@user = User.create!(name: "Ming",
  email: "ming.hentech@gmail.com",
  password: "password",
  password_confirmation: "password",
  activated: true,
  activated_at: Time.zone.now)

## admin user's division ##
@user.divisions.create!(
  name: "Coding"
)

## sample records ##


## accounts ##
Account.create!(
  name: "売上"
)
Account.create!(
  name: "売掛金受領"
)
Account.create!(
  name: "被源泉徴収"
)
Account.create!(
  name: "消費税"
)
Account.create!(
  name: "旅費交通費"
)
Account.create!(
  name: "会議費"
)
Account.create!(
  name: "取材費"
)
Account.create!(
  name: "交際費"
)
Account.create!(
  name: "広告費"
)
Account.create!(
  name: "消耗品費"
)
Account.create!(
  name: "期末在庫(商品)"
)
Account.create!(
  name: "期首在庫(商品)"
)
Account.create!(
  name: "期末在庫(材料)"
)
Account.create!(
  name: "期首在庫(材料)"
)