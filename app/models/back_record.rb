class BackRecord < ApplicationRecord
  belongs_to :division, optional: true
  belongs_to :record, optional: true
  validates :division_id, presence: true

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
    stats[:debits][:transportation] = {title: "交通費", value: 34490}
    stats[:debits][:publicrelation] = {title: "広報費", value: 0}
    stats[:credits][:sales] = {title: "売上", value: 320120}
    stats[:results][:pl] = {title: "利益収支", value: 70000}
    stats[:results][:cache] = {title: "キャッシュ収支", value: -20400}
    stats[:factors][:receivable] = {title: "未回収債権", value: -90400}
    stats
  end

end
