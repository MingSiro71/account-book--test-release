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

  def self.stats
    stats = {}
    stats[:debits] = {}
    stats[:credits] = {}
    stats[:results] = {}
    stats[:factors] = {}
    stats[:info] = {}
    stats[:debits][:transportation] = {title: "交通費", value: 34490}
    stats[:debits][:publicrelation] = {title: "広報費", value: 0}
    stats[:credits][:sales] = {title: "売上", value: 320120}
    stats[:results][:pl] = {title: "利益収支", value: 70000}
    stats[:results][:cache] = {title: "キャッシュ収支", value: -20400}
    stats[:factors][:receivable] = {title: "未回収債権", value: -90400}
    stats[:info][:tax10] = {title: "消費税率別収支:10%", value: 84000}
    stats[:info][:tax8] = {title: "消費税率別収支:8%", value: -14000}
    stats[:info][:tax0] = {title: "消費税率別収支:非課税", value: 0}
    stats
  end

end
